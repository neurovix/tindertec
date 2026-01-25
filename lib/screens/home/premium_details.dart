import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:tindertec/services/stripe_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tindertec/services/in_app_purchase.dart';

class PremiumDetailsScreen extends StatefulWidget {
  const PremiumDetailsScreen({super.key});

  @override
  State<PremiumDetailsScreen> createState() => _PremiumDetailsScreenState();
}

class _PremiumDetailsScreenState extends State<PremiumDetailsScreen> {
  bool _isProcessing = false;
  InAppPurchaseService? _iapService;
  bool _isLoadingIAP = true;
  String? _productPrice;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _initializeIAP();
    }
  }

  Future<void> _loadProducts() async {
    const ids = {
      'tindertec_weekly',
      'tindertec_monthly',
      'tindertec_semiannual',
    };

    final response = await _inAppPurchase.queryProductDetails(ids);

    if (response.error != null || response.productDetails.isEmpty) {
      debugPrint('Error cargando productos IAP');
      return;
    }

    setState(() {
      _products = response.productDetails;
    });
  }

  @override
  void dispose() {
    _iapService?.dispose();
    super.dispose();
  }

  // Inicializar IAP para iOS
  Future<void> _initializeIAP() async {
    setState(() {
      _isLoadingIAP = true;
    });

    _iapService = InAppPurchaseService(
      onPurchaseCompleted: _handleIAPPurchaseCompleted,
      onPurchaseError: _handleIAPPurchaseError,
      onPurchasingStateChanged: (isPurchasing) {
        if (mounted) {
          setState(() {
            _isProcessing = isPurchasing;
          });
        }
      },
    );

    await _iapService!.initialize();

    await _iapService!.testProductConnection();

    // Obtener el precio del producto
    if (_iapService!.premiumProduct != null) {
      setState(() {
        _productPrice = _iapService!.premiumProduct!.price;
      });
    }

    setState(() {
      _isLoadingIAP = false;
    });
  }

  // Manejar compra completada de IAP
  void _handleIAPPurchaseCompleted(PurchaseDetails purchase) async {
    debugPrint('Compra IAP completada: ${purchase.productID}');

    // Aquí actualiza el estado premium del usuario en tu backend
    final user = Supabase.instance.client.auth.currentUser;
    final String? userId = user?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('No se pudo encontrar una sesion activa')),
      );
    }

    try {
      final _ = await Supabase.instance.client
          .from("users")
          .update({'is_premium': true})
          .eq('id_user', userId.toString());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar a premium.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _showSuccessDialog();
  }

  // Manejar error de IAP
  void _handleIAPPurchaseError(String error) {
    if (error.toLowerCase().contains('cancelad')) {
      // No mostrar error si el usuario canceló
      return;
    }
    _showErrorDialog(error);
  }

  // Función para manejar compra con IAP (iOS)
  Future<void> _handleIAPPurchase(String productId) async {
    final product = _products.firstWhere((p) => p.id == productId);

    final purchaseParam = PurchaseParam(productDetails: product);

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Restaurar compras (iOS)
  Future<void> _restorePurchases() async {
    if (_iapService == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _iapService!.restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compras restauradas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al restaurar compras');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  int _getSubscriptionPrice(String planName) {
    switch (planName) {
      case 'Semanal':
        return 2000;
      case 'Mensual':
        return 6000;
      default:
        return 10000;
    }
  }

  // Función para manejar el pago con Stripe (Android)
  Future<void> _handleStripePayment(String planName) async {
    final user = Supabase.instance.client.auth.currentUser;
    final String? userId = user?.id;
    final String? userEmail = user?.email;

    // 🔴 Validación de email
    if (userEmail == null || userEmail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el correo del usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔴 Validación de id
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el uuid del usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await StripeService.processPayment(
        amount: _getSubscriptionPrice(planName),
        currency: 'mxn',
        context: context,
        userEmail: userEmail,
      );

      if (success) {
        if (!mounted) return;

        try {
          final _ = await Supabase.instance.client
              .from("users")
              .update({'is_premium': true})
              .eq('id_user', userId);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo actualizar a premium.'),
              backgroundColor: Colors.red,
            ),
          );
        }

        _showSuccessDialog();
      } else {
        if (!mounted) return;
        _showErrorDialog('El pago fue cancelado o falló. Intenta nuevamente.');
      }
    } catch (e) {
      debugPrint('Error en el pago: $e');
      if (!mounted) return;
      _showErrorDialog(
        'Ocurrió un error inesperado. Por favor, intenta nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Pago Exitoso!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Ahora eres usuario Premium. ¡Disfruta de todos los beneficios!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pinkAccent, Colors.purpleAccent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade50, Colors.white, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, size: 24),
                            ),
                          ),
                          // Botón de restaurar compras (solo iOS)
                          if (Platform.isIOS)
                            TextButton(
                              onPressed: _isProcessing
                                  ? null
                                  : _restorePurchases,
                              child: const Text(
                                'Restaurar',
                                style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.pinkAccent,
                                    Colors.purpleAccent,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Beneficios de volverte',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.pinkAccent, Colors.purpleAccent],
                            ).createShader(bounds),
                            child: const Text(
                              'PREMIUM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.pinkAccent.withOpacity(0.15),
                                      Colors.purpleAccent.withOpacity(0.15),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Beneficio',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          'Normal',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          'Premium',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.pinkAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildBenefitRow(
                                '🔥 Likes diarios',
                                '30',
                                'Ilimitados',
                                0,
                              ),
                              _buildDivider(),
                              _buildBenefitRow(
                                '💖 Ver a quién le gustas',
                                '❌',
                                '✅',
                                1,
                              ),
                              _buildDivider(),
                              _buildBenefitRow(
                                '⏮️ Retroceder perfiles',
                                '❌',
                                '✅',
                                3,
                              ),
                              _buildDivider(),
                              _buildBenefitRow('✍️ Editar perfil', '❌', '✅', 4),
                              _buildDivider(),
                              _buildBenefitRow(
                                '🙈 Alerta de match',
                                '❌',
                                '✅',
                                5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Semanal
                            Expanded(
                              child: _buildSubscriptionCard(
                                title: 'Semanal',
                                price: '20 MXN',
                                productId: 'tindertec_premium_weekly',
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Mensual
                            Expanded(
                              child: _buildSubscriptionCard(
                                title: 'Mensual',
                                price: '50 MXN',
                                productId: 'tindertec_premium_monthly',
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Semestral
                            Expanded(
                              child: _buildSubscriptionCard(
                                title: 'Semestral',
                                price: '100 MXN',
                                productId: 'tindertec_premium_semesterly',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Overlay de procesamiento
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.pinkAccent),
                          SizedBox(height: 16),
                          Text(
                            'Procesando pago...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(
    String benefit,
    String normal,
    String premium,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                normal,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.15),
                      Colors.purpleAccent.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  premium,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String productId,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (Platform.isIOS)
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: (_isProcessing || _isLoadingIAP)
                    ? null
                    : () => _handleIAPPurchase(productId),
                child: Center(
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Suscribirme",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          )
        else if (Platform.isAndroid)
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isProcessing ? null : () => _handleStripePayment(title),
                child: Center(
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Pagar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
