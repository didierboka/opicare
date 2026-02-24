import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/error/failures.dart';
import 'package:opicare/features/iap/domain/entities/purchase_entity.dart';
import 'package:opicare/features/iap/domain/usecases/get_products_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/purchase_product_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/restore_purchases_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/verify_purchase_usecase.dart';
import 'package:opicare/features/iap/domain/usecases/listen_purchase_updates_usecase.dart';
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
  final PurchaseProductUseCase purchaseProductUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final VerifyPurchaseUseCase verifyPurchaseUseCase;

  final ListenPurchaseUpdatesUseCase listenPurchaseUpdatesUseCase;

  StreamSubscription? _purchaseUpdatesSubscription;
  final List<PurchaseEntity> _restoredPurchases = [];

  IapBloc({
    required this.getProductsUseCase,
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

    _purchaseUpdatesSubscription = listenPurchaseUpdatesUseCase().listen(
      (purchase) {
        if (purchase.status == PurchaseStatus.restored) {
          add(PurchaseRestored(purchase: purchase));
        }
      },
    );
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapLoading());
    
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
    
    final result = await purchaseProductUseCase.execute(
      productId: event.productId,
    );

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (purchase) {
        // Vérifier automatiquement l'achat après l'achat réussi
        if (purchase.verificationData != null) {
          add(VerifyPurchase(
            purchaseId: purchase.purchaseId,
            productId: purchase.productId,
            verificationData: purchase.verificationData!,
          ));
        }
        emit(IapPurchaseSuccess(purchase: purchase));
      },
    );
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<IapState> emit,
  ) async {
    emit(const IapRestoring());
    
    final result = await restorePurchasesUseCase.execute();

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (purchases) => emit(IapRestoreSuccess(purchases: purchases)),
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
    );

    result.fold(
      (failure) => emit(IapError(failure: failure)),
      (isValid) {
        if (isValid) {
          emit(const IapVerificationSuccess());
        } else {
          emit(const IapError(failure: ServerFailure('Vérification échouée')));
        }
      },
    );
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
