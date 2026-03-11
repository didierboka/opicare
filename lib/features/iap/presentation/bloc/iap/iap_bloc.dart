import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
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
  final PurchaseProductUseCase purchaseProductUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final VerifyPurchaseUseCase verifyPurchaseUseCase;

  final ListenPurchaseUpdatesUseCase listenPurchaseUpdatesUseCase;

  StreamSubscription? _purchaseUpdatesSubscription;
  final List<PurchaseEntity> _restoredPurchases = [];
  double? _pendingAmount;
  String? _pendingCurrencyCode;

  IapBloc({
    required this.getProductsUseCase,
    required this.getActiveSubscriptionUseCase,
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

      // UX iOS: un "restored" peut arriver lors d'une tentative d'achat si l'abonnement existe déjà.
      // Dans ce cas on affiche l'état "abonnement actif" plutôt qu'un snack de restauration.
      if (currentState is IapPurchasing) {
        final subResult = await getActiveSubscriptionUseCase.execute();
        subResult.fold(
          (_) => emit(const IapPurchaseFailed(
            message: 'Vous avez déjà un abonnement actif. Rendez-vous sur le tableau de bord.',
          )),
          (sub) {
            if (sub != null && sub.isActive) {
              emit(IapActiveSubscription(subscription: sub, fromRestoreOrFirstPurchase: true));
            } else {
              emit(const IapPurchaseFailed(
                message: 'Cet abonnement semble déjà actif. Utilisez « Restaurer les achats » si nécessaire.',
              ));
            }
          },
        );
        return;
      }

      _restoredPurchases.add(purchase);
      if (currentState is IapRestoring) {
        final subResult = await getActiveSubscriptionUseCase.execute();
        subResult.fold(
          (_) => emit(IapRestoreSuccess(purchases: List<PurchaseEntity>.from(_restoredPurchases))),
          (sub) {
            if (sub != null && sub.isActive) {
              emit(IapActiveSubscription(subscription: sub, fromRestoreOrFirstPurchase: true));
            } else {
              emit(IapRestoreSuccess(purchases: List<PurchaseEntity>.from(_restoredPurchases)));
            }
          },
        );
      } else if (currentState is! IapActiveSubscription ||
          !(currentState as IapActiveSubscription).fromRestoreOrFirstPurchase) {
        emit(IapRestoreSuccess(purchases: List<PurchaseEntity>.from(_restoredPurchases)));
      }
      return;
    }

    final currentState = state;
    final isCurrentPurchase = currentState is IapPurchasing &&
        (purchase.productId == currentState.productId || purchase.productId.isEmpty);

    if (!isCurrentPurchase) return;

    switch (purchase.status) {
      case PurchaseStatus.purchased:
        // Nécessite un productId pour la validation (Android envoie parfois un productId vide en erreur uniquement).
        if (purchase.productId.isEmpty) return;
        // Loggue le retour du store au format attendu (platform, idpat, productId, etc.).
        IapCompletionLogger.logPurchaseCompletion(purchase);
        // Ne pas afficher l'écran de félicitations tout de suite : on appelle d'abord l'API de validation.
        add(VerifyPurchase(
          purchaseId: purchase.purchaseId,
          productId: purchase.productId,
          verificationData: purchase.verificationData ?? '',
          amount: _pendingAmount,
          currencyCode: _pendingCurrencyCode,
          purchase: purchase,
        ));
        break;
      case PurchaseStatus.cancelled:
        emit(const IapPurchaseFailed(message: 'Vous avez annulé l\'achat.'));
        break;
      case PurchaseStatus.error:
        final msg = purchase.errorMessage ?? 'L\'achat n\'a pas abouti. Réessayez.';
        emit(IapPurchaseFailed(message: msg));
        break;
      case PurchaseStatus.pending:
        // Toujours en cours, ne rien changer
        break;
      default:
        emit(IapPurchaseFailed(message: 'L\'achat n\'a pas abouti. Réessayez.'));
        break;
    }
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapLoading());

    final subResult = await getActiveSubscriptionUseCase.execute();
    subResult.fold(
      (failure) => null,
      (sub) {
        if (sub != null && sub.isActive) {
          emit(IapActiveSubscription(subscription: sub));
          return;
        }
      },
    );
    if (state is IapActiveSubscription) return;

    final result = await getProductsUseCase.execute(
      productIds: event.productIds,
    );

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (products) => emit(IapProductsLoaded(products: products)),
    );
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<IapState> emit,
  ) async {
    emit(IapPurchasing(productId: event.productId));
    _pendingAmount = event.amount;
    _pendingCurrencyCode = event.currencyCode;

    final result = await purchaseProductUseCase.execute(
      productId: event.productId,
    );

    result.fold(
      (failure) => emit(IapError(failure: failure)),
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

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (purchases) {
        // Les achats restaurés réels arrivent via le stream → PurchaseRestored.
        // Si le store ne renvoie rien (liste vide), on émet quand même pour sortir de IapRestoring
        // et afficher "Aucun achat à restaurer" (géré dans l'UI).
        emit(IapRestoreSuccess(purchases: purchases));
      },
    );
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
    );

    Failure? fail;
    bool? isValid;
    result.fold(
      (f) => fail = f,
      (v) => isValid = v,
    );
    if (fail != null) {
      if (event.purchase != null) {
        emit(IapPurchaseFailed(message: fail!.message));
      } else {
        emit(IapError(failure: fail!));
      }
      return;
    }
    if (isValid != true) {
      if (event.purchase != null) {
        emit(const IapPurchaseFailed(
          message: 'La validation du paiement a échoué. Réessayez ou contactez le support.',
        ));
      } else {
        emit(const IapError(failure: ServerFailure('Impossible de vérifier l\'achat. Réessayez plus tard.')));
      }
      return;
    }
    if (event.purchase == null) {
      emit(const IapVerificationSuccess());
      return;
    }
    final subResult = await getActiveSubscriptionUseCase.execute();
    final daysRemaining = subResult.fold(
      (_) => 0,
      (sub) => sub?.daysRemaining ?? 0,
    );
    emit(IapPurchaseSuccess(purchase: event.purchase!, daysRemaining: daysRemaining));
  }

  void _onResetIapState(
    ResetIapState event,
    Emitter<IapState> emit,
  ) {
    emit(const IapInitial());
  }

  void _onPurchaseRestored(
    PurchaseRestored event,
    Emitter<IapState> emit,
  ) {
    _restoredPurchases.add(event.purchase);
    emit(IapRestoreSuccess(purchases: List<PurchaseEntity>.from(_restoredPurchases)));
  }

  @override
  Future<void> close() {
    _purchaseUpdatesSubscription?.cancel();
    return super.close();
  }
}
