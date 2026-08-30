import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/usecases/complete_purchase_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/get_active_subscription_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/get_products_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/purchase_product_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/restore_purchases_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/verify_purchase_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/listen_purchase_updates_usecase.dart';
import 'package:opicare/features/iap/data/services/iap_completion_logger.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_event.dart';
import 'package:opicare/features/iap/presentation/bloc/iap/iap_state.dart';

/// * Jan, 2025
/// * Created by didierboka
/// * Author: Didier BOKA <didierboka.developer@gmail.com>
/// * or <didier.boka@synelia.tech>
///
/// # IAP Bloc
///
/// Bloc pour la gestion des achats in-app

class IapBloc extends Bloc<IapEvent, IapState> {
  final GetProductsUseCase getProductsUseCase;
  final GetActiveSubscriptionUseCase getActiveSubscriptionUseCase;
  final CompletePurchaseUseCase completePurchaseUseCase;
  final PurchaseProductUseCase purchaseProductUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final VerifyPurchaseUseCase verifyPurchaseUseCase;

  final ListenPurchaseUpdatesUseCase listenPurchaseUpdatesUseCase;

  StreamSubscription? _purchaseUpdatesSubscription;
  final List<PurchaseEntity> _restoredPurchases = [];
  double? _pendingAmount;
  String? _pendingCurrencyCode;
  String? _pendingPatientId;
  bool _pendingIsFamilyPurchase = false;
  Timer? _purchaseWatchdog;
  static const Duration _purchaseTimeout = Duration(seconds: 90);

  void _startPurchaseWatchdog({required String productId}) {
    _purchaseWatchdog?.cancel();
    _purchaseWatchdog = Timer(_purchaseTimeout, () {
      final s = state;
      if (s is IapPurchasing || s is IapPendingPayment || s is IapVerifying) {
        add(const ResetIapState());
      }
    });
  }

  void _stopPurchaseWatchdog() {
    _purchaseWatchdog?.cancel();
    _purchaseWatchdog = null;
  }

  IapBloc({
    required this.getProductsUseCase,
    required this.getActiveSubscriptionUseCase,
    required this.completePurchaseUseCase,
    required this.purchaseProductUseCase,
    required this.restorePurchasesUseCase,
    required this.verifyPurchaseUseCase,
    required this.listenPurchaseUpdatesUseCase,
  }) : super(const IapInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<VerifyPurchase>(_onVerifyPurchase);
    on<ResetIapState>(_onResetIapState);
    on<PurchaseRestored>(_onPurchaseRestored);
    on<PurchaseUpdateReceived>(_onPurchaseUpdateReceived);

    _purchaseUpdatesSubscription = listenPurchaseUpdatesUseCase().listen(
      (purchase) {
        add(PurchaseUpdateReceived(purchase: purchase));
      },
    );
  }

  Future<void> _onPurchaseUpdateReceived(
    PurchaseUpdateReceived event,
    Emitter<IapState> emit,
  ) async {
    final purchase = event.purchase;

    if (purchase.status == PurchaseStatus.restored) {
      final currentState = state;
      final inFlightPurchase = currentState is IapPurchasing || currentState is IapPendingPayment;

      if (inFlightPurchase) {
        final currentProductId = currentState is IapPurchasing
            ? currentState.productId
            : (currentState as IapPendingPayment).productId;
        final isCurrentPurchase = purchase.productId.isEmpty || purchase.productId == currentProductId;
        if (isCurrentPurchase) {
          await _verifyStorePurchase(purchase, emit, fallbackProductId: currentProductId);
          return;
        }
        await completePurchaseUseCase.execute(purchase);
        return;
      }

      if (currentState is IapRestoring) {
        _restoredPurchases.add(purchase);
        final restoredList = List<PurchaseEntity>.from(_restoredPurchases);
        final subResult = await getActiveSubscriptionUseCase.execute();
        subResult.fold(
          (_) => emit(IapRestoreSuccess(purchases: restoredList, subscriptionExpired: true)),
          (sub) {
            if (sub != null && sub.isActive) {
              emit(IapActiveSubscription(subscription: sub, fromRestoreOrFirstPurchase: true));
            } else {
              emit(IapRestoreSuccess(purchases: restoredList, subscriptionExpired: true));
            }
          },
        );
        return;
      }

      // Consumable: an unsolicited restored event is an unfinished StoreKit transaction.
      // Finish it so the next buy can show a payment sheet. Do not verify without a known beneficiary.
      await completePurchaseUseCase.execute(purchase);
      return;
    }

    final currentState = state;
    final String currentProductId = currentState is IapPurchasing
        ? currentState.productId
        : currentState is IapPendingPayment
            ? currentState.productId
            : '';
    final isCurrentPurchase = currentProductId.isNotEmpty && (purchase.productId == currentProductId || purchase.productId.isEmpty);

    if (!isCurrentPurchase) return;

    switch (purchase.status) {
      case PurchaseStatus.purchased:
        await _verifyStorePurchase(purchase, emit, fallbackProductId: currentProductId);
        break;
      case PurchaseStatus.cancelled:
        _stopPurchaseWatchdog();
        emit(const IapPurchaseFailed(message: 'Vous avez annulé l\'achat.'));
        break;
      case PurchaseStatus.error:
        _stopPurchaseWatchdog();
        final msg = purchase.errorMessage ?? 'L\'achat n\'a pas abouti. Réessayez.';
        emit(IapPurchaseFailed(message: msg));
        break;
      case PurchaseStatus.pending:
        emit(IapPendingPayment(productId: currentProductId));
        break;
      default:
        _stopPurchaseWatchdog();
        emit(IapPurchaseFailed(message: 'L\'achat n\'a pas abouti. Réessayez.'));
        break;
    }
  }

  Future<void> _verifyStorePurchase(
    PurchaseEntity purchase,
    Emitter<IapState> emit, {
    required String fallbackProductId,
  }) async {
    _stopPurchaseWatchdog();
    final resolvedProductId = purchase.productId.isNotEmpty ? purchase.productId : fallbackProductId;
    if (resolvedProductId.isEmpty) {
      emit(const IapPurchaseFailed(
        message: 'Le paiement a été reçu mais le produit est introuvable. Veuillez réessayer.',
      ));
      return;
    }
    await IapCompletionLogger.logPurchaseCompletion(purchase);
    add(VerifyPurchase(
      purchaseId: purchase.purchaseId,
      productId: resolvedProductId,
      verificationData: purchase.verificationData ?? '',
      amount: _pendingAmount,
      currencyCode: _pendingCurrencyCode,
      patientId: _pendingPatientId,
      purchase: purchase,
    ));
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<IapState> emit) async {
    emit(const IapLoading());

    if (!event.ignoreLocalSubscription) {
      final subResult = await getActiveSubscriptionUseCase.execute();
      final active = subResult.fold((_) => null, (sub) => sub);
      if (active != null && active.isActive) {
        emit(IapActiveSubscription(
          subscription: active,
          fromRestoreOrFirstPurchase: false,
        ));
        return;
      }
    }

    final result = await getProductsUseCase.execute(
      productIds: event.productIds,
    );

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (products) => emit(IapProductsLoaded(products: products)),
    );
  }

  Future<void> _onPurchaseProduct(PurchaseProduct event, Emitter<IapState> emit) async {
    if (event.patientId.trim().isEmpty) {
      emit(const IapPurchaseFailed(
        message: 'Compte bénéficiaire introuvable. Impossible de lancer l\'achat.',
      ));
      return;
    }

    debugPrint(
      'IAP PurchaseProduct patientId=${event.patientId} productId=${event.productId}',
    );

    emit(IapPurchasing(productId: event.productId));

    _startPurchaseWatchdog(productId: event.productId);

    _pendingAmount = event.amount;
    _pendingCurrencyCode = event.currencyCode;
    _pendingPatientId = event.patientId;
    _pendingIsFamilyPurchase = event.isFamilyPurchase;

    final result = await purchaseProductUseCase.execute(
      productId: event.productId,
    );

    result.fold(
      (failure) {
        _stopPurchaseWatchdog();
        emit(IapPurchaseFailed(message: failure.message));
      },
      (_) {
        // Ne pas émettre IapPurchaseSuccess ici : le résultat réel (purchased / cancelled / error)
        // arrive via le stream purchaseUpdates. On reste en IapPurchasing jusqu'à réception.
      },
    );
  }

  Future<void> _onRestorePurchases(RestorePurchases event, Emitter<IapState> emit) async {
    _restoredPurchases.clear();
    emit(const IapRestoring());

    final result = await restorePurchasesUseCase.execute();

    Failure? fail;
    result.fold((f) => fail = f, (_) {});
    if (fail != null) {
      emit(IapError(failure: fail!));
      return;
    }

    // Passes consommables : Apple/Google restore est souvent vide.
    // L'abonnement réel est côté Opicare (dateExpiration du compte connecté).
    final subResult = await getActiveSubscriptionUseCase.execute();
    final active = subResult.fold((_) => null, (sub) => sub);
    if (active != null && active.isActive) {
      emit(IapActiveSubscription(
        subscription: active,
        fromRestoreOrFirstPurchase: true,
      ));
      return;
    }

    emit(const IapRestoreSuccess(purchases: [], subscriptionExpired: true));
  }

  Future<void> _onVerifyPurchase(
    VerifyPurchase event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapVerifying());

    final result = await verifyPurchaseUseCase.execute(
      purchaseId: event.purchaseId,
      productId: event.productId,
      verificationData: event.verificationData,
      amount: event.amount,
      currencyCode: event.currencyCode,
      patientId: event.patientId,
    );

    Failure? fail;
    bool? isValid;
    result.fold(
      (f) => fail = f,
      (v) => isValid = v,
    );
    if (fail != null) {
      _stopPurchaseWatchdog();
      if (event.purchase != null) {
        emit(IapPurchaseActivationPending(
          purchase: event.purchase!,
          message: '${fail!.message} Votre paiement peut avoir été reçu. Réessayez la validation.',
          amount: event.amount,
          currencyCode: event.currencyCode,
          patientId: event.patientId,
        ));
      } else {
        emit(IapError(failure: fail!));
      }
      return;
    }
    if (isValid != true) {
      _stopPurchaseWatchdog();
      if (event.purchase != null) {
        emit(IapPurchaseActivationPending(
          purchase: event.purchase!,
          message: 'La validation du paiement a échoué. Votre paiement peut avoir été reçu. Réessayez la validation.',
          amount: event.amount,
          currencyCode: event.currencyCode,
          patientId: event.patientId,
        ));
      } else {
        emit(const IapError(failure: ServerFailure('Impossible de vérifier l\'achat. Réessayez plus tard.')));
      }
      return;
    }
    if (event.purchase == null) {
      _stopPurchaseWatchdog();
      emit(const IapVerificationSuccess());
      return;
    }

    final completeResult = await completePurchaseUseCase.execute(event.purchase!);
    Failure? completionFailure;
    completeResult.fold((failure) => completionFailure = failure, (_) => null);
    if (completionFailure != null) {
      _stopPurchaseWatchdog();
      emit(IapPurchaseActivationPending(
        purchase: event.purchase!,
        message: completionFailure!.message,
        amount: event.amount,
        currencyCode: event.currencyCode,
        patientId: event.patientId,
      ));
      return;
    }

    final daysRemaining = _pendingIsFamilyPurchase
        ? 365
        : (await getActiveSubscriptionUseCase.execute()).fold(
            (_) => 0,
            (sub) => sub?.daysRemaining ?? 0,
          );
    _stopPurchaseWatchdog();
    emit(IapPurchaseSuccess(purchase: event.purchase!, daysRemaining: daysRemaining));
  }

  void _onResetIapState(ResetIapState event, Emitter<IapState> emit,) {
    _stopPurchaseWatchdog();
    _pendingAmount = null;
    _pendingCurrencyCode = null;
    _pendingPatientId = null;
    _pendingIsFamilyPurchase = false;
    emit(const IapInitial());
  }

  void _onPurchaseRestored(
    PurchaseRestored event,
    Emitter<IapState> emit,
  ) {
    _restoredPurchases.add(event.purchase);
    emit(IapRestoreSuccess(purchases: List<PurchaseEntity>.from(_restoredPurchases), subscriptionExpired: false));
  }

  @override
  Future<void> close() {
    _purchaseUpdatesSubscription?.cancel();
    _stopPurchaseWatchdog();
    return super.close();
  }
}
