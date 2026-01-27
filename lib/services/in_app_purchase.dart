import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Timer? _purchaseTimeout;

  // IDs de los productos de suscripción
  static const String weeklyProductId = 'tindertec_premium_weekly';
  static const String monthlyProductId = 'tindertec_premium_monthly';
  static const String semiannualProductId = 'tindertec_premium_semesterly';

  // ID legacy para compatibilidad
  static const String legacyProductId = 'tindertec_premium';

  static const List<String> _productIds = [
    weeklyProductId,
    monthlyProductId,
    semiannualProductId,
  ];

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  // Getter para compatibilidad con código antiguo (retorna el primer producto)
  ProductDetails? get premiumProduct =>
      _products.isEmpty ? null : _products.first;

  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isPurchasing = false;
  bool get isPurchasing => _isPurchasing;

  // Callbacks
  final void Function(PurchaseDetails)? onPurchaseCompleted;
  final void Function(String)? onPurchaseError;
  final void Function(bool)? onPurchasingStateChanged;
  final void Function()? onProductsLoaded;

  InAppPurchaseService({
    this.onPurchaseCompleted,
    this.onPurchaseError,
    this.onPurchasingStateChanged,
    this.onProductsLoaded,
  });

  /// Inicializar el servicio de compras
  Future<void> initialize() async {
    // ✅ CRÍTICO: Registrar la plataforma ANTES de cualquier cosa
    if (Platform.isIOS) {
      InAppPurchaseStoreKitPlatform.registerPlatform();
    }

    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        _updatePurchasingState(false);
        onPurchaseError?.call(error.toString());
      },
    );

    // ✅ Configurar delegate en iOS (DESPUÉS del listener)
    if (Platform.isIOS) {
      final iosAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      await iosAddition.setDelegate(PaymentQueueDelegate());

      final transactions = await SKPaymentQueueWrapper().transactions();
      for (var transaction in transactions) {
        await SKPaymentQueueWrapper().finishTransaction(transaction);
      }
    }

    // ✅ AHORA sí cargar productos
    await loadProducts();
  }

  /// Cargar productos desde la tienda
  Future<void> loadProducts() async {
    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        onPurchaseError?.call(
          'No se pudieron cargar los productos: ${response.error!.message}',
        );
        return;
      }

      if (response.productDetails.isEmpty) {
        onPurchaseError?.call('No se encontraron productos en la tienda');
        return;
      }

      _products = response.productDetails;

      // Notificar que los productos se cargaron
      onProductsLoaded?.call();
    } catch (e) {
      onPurchaseError?.call('Error al cargar productos: $e');
    }
  }

  /// Comprar suscripción Premium (método legacy para compatibilidad)
  Future<void> buyPremiumSubscription() async {
    // Usar el primer producto disponible
    if (_products.isEmpty) {
      onPurchaseError?.call('No hay productos disponibles');
      return;
    }

    await buySubscription(_products.first.id);
  }

  /// Comprar suscripción por ID de producto
  Future<void> buySubscription(String productId) async {
    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    if (_isPurchasing) {
      return;
    }

    final product = getProductById(productId);
    if (product == null) {
      onPurchaseError?.call('El producto no está disponible');
      return;
    }

    _updatePurchasingState(true);

    // Timeout de seguridad: Si después de 60 segundos no hay respuesta, resetear el estado
    _purchaseTimeout?.cancel();
    _purchaseTimeout = Timer(const Duration(seconds: 60), () {
      if (_isPurchasing) {
        _updatePurchasingState(false);
        onPurchaseError?.call('La operación tomó demasiado tiempo');
      }
    });

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Para suscripciones, usa buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _purchaseTimeout?.cancel();
        _updatePurchasingState(false);
        onPurchaseError?.call('No se pudo iniciar la compra');
      }
      // Si success es true, el estado se actualizará en _onPurchaseUpdate
      // cuando llegue el evento de compra (purchased, canceled, error, etc)
    } catch (e) {
      _purchaseTimeout?.cancel();
      _updatePurchasingState(false);
      onPurchaseError?.call('Error al procesar la compra');
    }
  }

  /// Restaurar compras previas
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      onPurchaseError?.call('Error al restaurar compras');
    }
  }

  /// Manejar actualizaciones de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      // Cancelar timeout cuando recibimos una actualización
      _purchaseTimeout?.cancel();

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _updatePurchasingState(true);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _updatePurchasingState(false);

        String errorMessage = 'Error en la compra';
        if (purchaseDetails.error?.code ==
            'storekit_duplicate_product_object') {
          errorMessage = 'Ya tienes una compra en proceso';
        } else if (purchaseDetails.error?.message != null) {
          errorMessage = purchaseDetails.error!.message;
        }

        onPurchaseError?.call(errorMessage);

        // Completar la compra fallida
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyAndDeliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _updatePurchasingState(false);

        // Completar la transacción cancelada para limpiarla de la cola
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }

        // Notificar la cancelación
        onPurchaseError?.call('Compra cancelada');
      }
    }
  }

  /// Verificar y entregar el producto comprado
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANTE: En producción, debes verificar la compra en tu servidor
    // Envía el verificationData.serverVerificationData a tu backend
    // para verificar con Apple antes de entregar el producto

    try {
      // Aquí deberías llamar a tu backend para verificar
      // final isValid = await verifyPurchaseWithBackend(purchaseDetails);

      // Por ahora, asumimos que es válida
      _updatePurchasingState(false);
      onPurchaseCompleted?.call(purchaseDetails);

      // ✅ CRÍTICO: Marcar como completada
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      _updatePurchasingState(false);
      onPurchaseError?.call('Error al verificar la compra');
    }
  }

  void _updatePurchasingState(bool isPurchasing) {
    _isPurchasing = isPurchasing;
    onPurchasingStateChanged?.call(isPurchasing);
  }

  /// Limpiar recursos
  void dispose() {
    _purchaseTimeout?.cancel();
    _subscription.cancel();
  }
}

/// Delegado para manejar la cola de pagos en iOS
class PaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
