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
      debugPrint('❌ Producto no encontrado: $productId');
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

  /// 🧪 MÉTODO DE PRUEBA - Verificar productos disponibles
  Future<void> testProductConnection() async {
    debugPrint('🧪 === INICIANDO TEST DE CONEXIÓN ===');

    // Test 1: Verificar disponibilidad
    final available = await _inAppPurchase.isAvailable();
    debugPrint('🧪 Test 1 - Tienda disponible: $available');

    if (!available) {
      debugPrint('❌ La tienda no está disponible');
      return;
    }

    // Test 2: Probar con múltiples Product IDs
    final testIds = {
      'tindertec_premium',
      'tindertec_premium_weekly',
      'tindertec_premium_monthly',
      'tindertec_premium_semesterly',
    };

    debugPrint('🧪 Test 2 - Probando Product IDs: $testIds');

    for (final id in testIds) {
      debugPrint('🧪 Probando: $id');
      final response = await _inAppPurchase.queryProductDetails({id});

      debugPrint('🧪 Response para $id:');
      debugPrint('   - Error: ${response.error}');
      debugPrint(
        '   - Productos encontrados: ${response.productDetails.length}',
      );

      if (response.productDetails.isNotEmpty) {
        debugPrint('✅ ¡PRODUCTO ENCONTRADO!');
        for (var product in response.productDetails) {
          debugPrint('   📦 ID: ${product.id}');
          debugPrint('   💰 Precio: ${product.price}');
        }
      }
    }

    debugPrint('🧪 === FIN DEL TEST ===');
  }

  /// Inicializar el servicio de compras
  Future<void> initialize() async {
    debugPrint('🚀 Iniciando servicio IAP');

    // ✅ CRÍTICO: Registrar la plataforma ANTES de cualquier cosa
    if (Platform.isIOS) {
      debugPrint('📲 Registrando plataforma StoreKit');
      InAppPurchaseStoreKitPlatform.registerPlatform();
    }

    _isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('🪙 Tienda disponible: $_isAvailable');

    if (!_isAvailable) {
      debugPrint('❌ La tienda no está disponible');
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    // ✅ Configurar el listener ANTES de cargar productos
    debugPrint('📡 Configurando listener de compras');
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        debugPrint('✅ Stream de compras completado');
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('❌ Error en stream: $error');
        _updatePurchasingState(false);
        onPurchaseError?.call(error.toString());
      },
    );

    // ✅ Configurar delegate en iOS (DESPUÉS del listener)
    if (Platform.isIOS) {
      debugPrint('🔧 Configurando PaymentQueueDelegate');
      final iosAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      await iosAddition.setDelegate(PaymentQueueDelegate());
    }

    // ✅ AHORA sí cargar productos
    await loadProducts();
  }

  /// Cargar productos desde la tienda
  Future<void> loadProducts() async {
    if (!_isAvailable) {
      debugPrint('⚠️ No se pueden cargar productos: tienda no disponible');
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    debugPrint('🛒 Cargando productos: $_productIds');

    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_productIds.toSet());

      if (response.error != null) {
        debugPrint('❌ Error al cargar productos: ${response.error}');
        onPurchaseError?.call(
          'No se pudieron cargar los productos: ${response.error!.message}',
        );
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('⚠️ No se encontraron productos');
        debugPrint('⚠️ Productos no encontrados: ${response.notFoundIDs}');
        onPurchaseError?.call('No se encontraron productos en la tienda');
        return;
      }

      _products = response.productDetails;
      debugPrint('✅ Productos cargados: ${_products.length}');
      for (var product in _products) {
        debugPrint('   📦 ${product.id} - ${product.price}');
      }

      // Notificar que los productos se cargaron
      onProductsLoaded?.call();
    } catch (e) {
      debugPrint('❌ Excepción al cargar productos: $e');
      onPurchaseError?.call('Error al cargar productos: $e');
    }
  }

  /// Comprar suscripción Premium (método legacy para compatibilidad)
  Future<void> buyPremiumSubscription() async {
    debugPrint('🛍️ buyPremiumSubscription llamado (método legacy)');

    // Usar el primer producto disponible
    if (_products.isEmpty) {
      debugPrint('❌ No hay productos disponibles');
      onPurchaseError?.call('No hay productos disponibles');
      return;
    }

    await buySubscription(_products.first.id);
  }

  /// Comprar suscripción por ID de producto
  Future<void> buySubscription(String productId) async {
    debugPrint('🛍️ Intentando comprar suscripción: $productId');

    if (!_isAvailable) {
      debugPrint('❌ Tienda no disponible');
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    if (_isPurchasing) {
      debugPrint('⚠️ Ya hay una compra en proceso');
      return;
    }

    final product = getProductById(productId);
    if (product == null) {
      debugPrint('❌ Producto no encontrado: $productId');
      onPurchaseError?.call('El producto no está disponible');
      return;
    }

    _updatePurchasingState(true);

    // Timeout de seguridad: Si después de 60 segundos no hay respuesta, resetear el estado
    _purchaseTimeout?.cancel();
    _purchaseTimeout = Timer(const Duration(seconds: 60), () {
      if (_isPurchasing) {
        debugPrint('⏰ Timeout: Reseteando estado de compra');
        _updatePurchasingState(false);
        onPurchaseError?.call('La operación tomó demasiado tiempo');
      }
    });

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      debugPrint('💳 Iniciando compra de: ${product.id}');

      // Para suscripciones, usa buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('📊 Resultado de buyNonConsumable: $success');

      if (!success) {
        debugPrint('❌ buyNonConsumable retornó false');
        _purchaseTimeout?.cancel();
        _updatePurchasingState(false);
        onPurchaseError?.call('No se pudo iniciar la compra');
      }
      // Si success es true, el estado se actualizará en _onPurchaseUpdate
      // cuando llegue el evento de compra (purchased, canceled, error, etc)
    } catch (e) {
      debugPrint('❌ Excepción al comprar: $e');
      _purchaseTimeout?.cancel();
      _updatePurchasingState(false);
      onPurchaseError?.call('Error al procesar la compra');
    }
  }

  /// Restaurar compras previas
  Future<void> restorePurchases() async {
    debugPrint('🔄 Restaurando compras');

    if (!_isAvailable) {
      onPurchaseError?.call('La tienda no está disponible');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restauración iniciada');
    } catch (e) {
      debugPrint('❌ Error al restaurar compras: $e');
      onPurchaseError?.call('Error al restaurar compras');
    }
  }

  /// Manejar actualizaciones de compras
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    debugPrint('📦 Actualizaciones de compra: ${purchaseDetailsList.length}');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint(
        '🔄 Estado: ${purchaseDetails.status} - Producto: ${purchaseDetails.productID}',
      );

      // Cancelar timeout cuando recibimos una actualización
      _purchaseTimeout?.cancel();

      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('⏳ Compra pendiente...');
        _updatePurchasingState(true);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('❌ Error en compra: ${purchaseDetails.error}');
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
        debugPrint('🎉 Compra exitosa/restaurada');
        _verifyAndDeliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('🚫 Compra cancelada por el usuario');
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
    debugPrint('✅ Verificando compra: ${purchaseDetails.productID}');

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
        debugPrint('✅ Completando compra');
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('❌ Error al verificar compra: $e');
      _updatePurchasingState(false);
      onPurchaseError?.call('Error al verificar la compra');
    }
  }

  void _updatePurchasingState(bool isPurchasing) {
    debugPrint('🔄 Estado de compra: $isPurchasing');
    _isPurchasing = isPurchasing;
    onPurchasingStateChanged?.call(isPurchasing);
  }

  /// Limpiar recursos
  void dispose() {
    debugPrint('🧹 Limpiando recursos IAP');
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
    debugPrint(
      '🔍 shouldContinueTransaction: ${transaction.transactionIdentifier}',
    );
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    debugPrint('🔍 shouldShowPriceConsent');
    return false;
  }
}
