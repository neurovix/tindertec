import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // ID del producto de suscripción
  static const String premiumSubscriptionId = 'tindertec_premium';

  static const List<String> _productIds = [
    premiumSubscriptionId,
  ];

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  ProductDetails? get premiumProduct =>
      _products.isEmpty ? null : _products.first;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isPurchasing = false;
  bool get isPurchasing => _isPurchasing;

  // Callbacks
  final void Function(PurchaseDetails)? onPurchaseCompleted;
  final void Function(String)? onPurchaseError;
  final void Function(bool)? onPurchasingStateChanged;

  InAppPurchaseService({
    this.onPurchaseCompleted,
    this.onPurchaseError,
    this.onPurchasingStateChanged,
  });

  /// Inicializar el servicio de compras
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      debugPrint('La tienda no está disponible');
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    // ✅ PRIMERO configurar StoreKit (ANTES de TODO)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosAddition =
      _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      await iosAddition.setDelegate(PaymentQueueDelegate());
    }

    // Listener
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint('Error en stream: $error');
        _updatePurchasingState(false);
        onPurchaseError?.call(error.toString());
      },
    );

    // ✅ AHORA sí cargar productos
    await loadProducts();
  }

  /// Cargar productos desde la tienda
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_productIds.toSet());

    if (response.error != null) {
      debugPrint('Error al cargar productos: ${response.error}');
      onPurchaseError?.call('No se pudieron cargar los productos');
      return;
    }

    if (response.productDetails.isEmpty) {
      debugPrint('No se encontraron productos');
      onPurchaseError?.call('No se encontró el producto Premium');
      return;
    }

    _products = response.productDetails;
    debugPrint('Producto cargado: ${_products.first.id} - ${_products.first.price}');
  }

  /// Comprar suscripción Premium
  Future<void> buyPremiumSubscription() async {
    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    if (_isPurchasing) {
      debugPrint('Ya hay una compra en proceso');
      return;
    }

    if (premiumProduct == null) {
      onPurchaseError?.call('El producto Premium no está disponible');
      return;
    }

    _updatePurchasingState(true);

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: premiumProduct!,
    );

    try {
      // Para suscripciones, usa buyNonConsumable
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );

      if (!success) {
        _updatePurchasingState(false);
        onPurchaseError?.call('No se pudo iniciar la compra');
      }
    } catch (e) {
      debugPrint('Error al comprar: $e');
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
      debugPrint('Error al restaurar compras: $e');
      onPurchaseError?.call('Error al restaurar compras');
    }
  }

  /// Verificar si el usuario tiene suscripción activa
  Future<bool> hasPremiumSubscription() async {
    if (!_isAvailable) return false;

    try {
      // Esto restaura las compras sin mostrar UI
      await _inAppPurchase.restorePurchases();

      // La verificación real se debe hacer en tu backend
      // Aquí solo verificamos localmente
      return false; // Implementa la lógica de verificación
    } catch (e) {
      debugPrint('Error al verificar suscripción: $e');
      return false;
    }
  }

  /// Manejar actualizaciones de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('Estado de compra: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Compra pendiente...');
        _updatePurchasingState(true);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Error en compra: ${purchaseDetails.error}');
        _updatePurchasingState(false);

        String errorMessage = 'Error en la compra';
        if (purchaseDetails.error?.code == 'storekit_duplicate_product_object') {
          errorMessage = 'Ya tienes una compra en proceso';
        } else if (purchaseDetails.error?.message != null) {
          errorMessage = purchaseDetails.error!.message;
        }

        onPurchaseError?.call(errorMessage);
        _inAppPurchase.completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyAndDeliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('Compra cancelada por el usuario');
        _updatePurchasingState(false);
        onPurchaseError?.call('Compra cancelada');
      }
    }
  }

  /// Verificar y entregar el producto comprado
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint('Verificando compra: ${purchaseDetails.productID}');

    // IMPORTANTE: En producción, debes verificar la compra en tu servidor
    // Envía el verificationData.serverVerificationData a tu backend
    // para verificar con Apple antes de entregar el producto

    try {
      // Aquí deberías llamar a tu backend para verificar
      // final isValid = await verifyPurchaseWithBackend(purchaseDetails);

      // Por ahora, asumimos que es válida
      _updatePurchasingState(false);
      onPurchaseCompleted?.call(purchaseDetails);

      // Marcar como completada
      await _inAppPurchase.completePurchase(purchaseDetails);
    } catch (e) {
      debugPrint('Error al verificar compra: $e');
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
    _subscription.cancel();
  }
}

/// Delegado para manejar la cola de pagos en iOS
class PaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}