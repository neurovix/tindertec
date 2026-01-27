import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:tindertec/services/stripe_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tindertec/services/in_app_purchase.dart';

class BecomePremiumScreen extends StatefulWidget {
  const BecomePremiumScreen({super.key});

  @override
  State<BecomePremiumScreen> createState() => _BecomePremiumState();
}

class _BecomePremiumState extends State<BecomePremiumScreen> {
  bool _isProcessing = false;
  InAppPurchaseService? _iapService;
  bool _isLoadingIAP = true;

  // Mapa de precios para iOS (se actualizan desde IAP)
  final Map<String, String> _iosPrices = {
    InAppPurchaseService.weeklyProductId: 'Cargando...',
    InAppPurchaseService.monthlyProductId: 'Cargando...',
    InAppPurchaseService.semiannualProductId: 'Cargando...',
  };

  // Precios fijos para Android
  static const Map<String, String> _androidPrices = {
    'Semanal': '20 MXN',
    'Mensual': '50 MXN',
    'Semestral': '100 MXN',
  };

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _initializeIAP();
    }
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
      onProductsLoaded: () {
        // Actualizar precios cuando los productos se cargan
        if (mounted) {
          _updateIOSPrices();
        }
      },
    );

    await _iapService!.initialize();

    // Ejecutar test de conexión (opcional, puedes comentarlo en producción)
    // await _iapService!.testProductConnection();

    setState(() {
      _isLoadingIAP = false;
    });
  }

  // Actualizar precios de iOS desde los productos cargados
  void _updateIOSPrices() {
    if (_iapService == null) return;

    setState(() {
      for (var product in _iapService!.products) {
        _iosPrices[product.id] = product.price;
      }
    });
  }

  // Obtener precio según plataforma
  String _getPrice(String productId, String planName) {
    if (Platform.isIOS) {
      return _iosPrices[productId] ?? 'N/A';
    } else {
      return _androidPrices[planName] ?? 'N/A';
    }
  }

  // Calcular fecha de expiración según el plan
  DateTime _calculatePremiumUntil(String productId) {
    final now = DateTime.now();

    if (productId == InAppPurchaseService.weeklyProductId) {
      // Semanal: +7 días
      return now.add(const Duration(days: 7));
    } else if (productId == InAppPurchaseService.monthlyProductId) {
      // Mensual: +30 días
      return now.add(const Duration(days: 30));
    } else if (productId == InAppPurchaseService.semiannualProductId) {
      // Semestral: +180 días (aproximadamente 6 meses)
      return now.add(const Duration(days: 180));
    }

    // Por defecto: +30 días
    return now.add(const Duration(days: 30));
  }

  // Manejar compra completada de IAP
  void _handleIAPPurchaseCompleted(PurchaseDetails purchase) async {
    final user = Supabase.instance.client.auth.currentUser;
    final String? userId = user?.id;

    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo encontrar una sesión activa'),
          ),
        );
      }
      return;
    }

    try {
      // Calcular fecha de expiración
      final premiumUntil = _calculatePremiumUntil(purchase.productID);

      await Supabase.instance.client
          .from("users")
          .update({
            'is_premium': true,
            'premium_until': premiumUntil.toIso8601String(),
          })
          .eq('id_user', userId);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar a premium.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Manejar error de IAP
  void _handleIAPPurchaseError(String error) {
    // No mostrar ningún mensaje si el usuario canceló
    if (error.toLowerCase().contains('cancelad')) {
      return;
    }

    // No mostrar error para timeout si no hay otra acción del usuario
    if (error.toLowerCase().contains('demasiado tiempo')) {
      return;
    }

    // Solo mostrar errores reales
    if (mounted) {
      _showErrorDialog(error);
    }
  }

  // Función para manejar compra con IAP (iOS)
  Future<void> _handleIAPPurchase(String productId) async {
    if (_iapService == null) {
      _showErrorDialog('Servicio de compras no disponible');
      return;
    }

    final exists = _iapService!.products.any((p) => p.id == productId);

    if (!exists) {
      _showErrorDialog('Producto no disponible en App Store');
      return;
    }

    await _iapService!.buySubscription(productId);
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
        return 5000;
      default:
        return 10000;
    }
  }

  // Función para manejar el pago con Stripe (Android)
  Future<void> _handleStripePayment(String planName) async {
    final user = Supabase.instance.client.auth.currentUser;
    final String? userId = user?.id;
    final String? userEmail = user?.email;

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

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el ID del usuario.'),
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
          // Calcular fecha de expiración según el plan
          final now = DateTime.now();
          DateTime premiumUntil;

          switch (planName) {
            case 'Semanal':
              premiumUntil = now.add(const Duration(days: 7));
              break;
            case 'Mensual':
              premiumUntil = now.add(const Duration(days: 30));
              break;
            case 'Semestral':
              premiumUntil = now.add(const Duration(days: 180));
              break;
            default:
              premiumUntil = now.add(const Duration(days: 30));
          }

          await Supabase.instance.client
              .from("users")
              .update({
                'is_premium': true,
                'premium_until': premiumUntil.toIso8601String(),
              })
              .eq('id_user', userId);

          _showSuccessDialog();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo actualizar a premium.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        _showErrorDialog('El pago fue cancelado o falló. Intenta nuevamente.');
      }
    } catch (e) {
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

  // Navegar al home
  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
              onPressed: _navigateToHome,
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
                      // Back Button y Restaurar
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
                                child: const Row(
                                  children: [
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
                              _buildBenefitRow('✏️ Editar perfil', '❌', '✅', 4),
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
                      // Tarjetas de suscripción
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
                                price: _getPrice(
                                  InAppPurchaseService.weeklyProductId,
                                  'Semanal',
                                ),
                                productId: InAppPurchaseService.weeklyProductId,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Mensual
                            Expanded(
                              child: _buildSubscriptionCard(
                                title: 'Mensual',
                                price: _getPrice(
                                  InAppPurchaseService.monthlyProductId,
                                  'Mensual',
                                ),
                                productId:
                                    InAppPurchaseService.monthlyProductId,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Semestral
                            Expanded(
                              child: _buildSubscriptionCard(
                                title: 'Semestral',
                                price: _getPrice(
                                  InAppPurchaseService.semiannualProductId,
                                  'Semestral',
                                ),
                                productId:
                                    InAppPurchaseService.semiannualProductId,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón "No por ahora"
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.lightGreenAccent],
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
                            onTap: _navigateToHome,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thumb_down,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "No por ahora",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Overlay de procesamiento
              if (_isProcessing || (Platform.isIOS && _isLoadingIAP))
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isLoadingIAP
                                ? 'Cargando productos...'
                                : 'Procesando pago...',
                            style: const TextStyle(
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
              onTap: (_isProcessing || (Platform.isIOS && _isLoadingIAP))
                  ? null
                  : () {
                      if (Platform.isIOS) {
                        _handleIAPPurchase(productId);
                      } else {
                        _handleStripePayment(title);
                      }
                    },
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
                        children: [
                          const Icon(
                            Icons.credit_card,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Platform.isIOS ? "Suscribirme" : "Pagar",
                            style: const TextStyle(
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
