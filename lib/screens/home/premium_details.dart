import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_stripe/flutter_stripe.dart';
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
    );

    await _iapService!.initialize();

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
  void _handleIAPPurchaseCompleted(PurchaseDetails purchase) {
    debugPrint('Compra IAP completada: ${purchase.productID}');

    // Aquí actualiza el estado premium del usuario en tu backend
    // await updateUserPremiumStatus(purchase.verificationData.serverVerificationData);

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
  Future<void> _handleIAPPurchase() async {
    if (_iapService == null || !_iapService!.isAvailable) {
      _showErrorDialog('La tienda no está disponible en este momento');
      return;
    }

    if (_iapService!.premiumProduct == null) {
      _showErrorDialog('El producto Premium no está disponible');
      return;
    }

    await _iapService!.buyPremiumSubscription();
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

  // Función para manejar el pago con Stripe (Android)
  Future<void> _handleStripePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await StripeService.processPayment(
        amount: 6000,
        currency: 'mxn',
        context: context,
        userEmail: 'usuario@ejemplo.com',
      );

      if (success) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        if (!mounted) return;
        _showErrorDialog('El pago fue cancelado o falló. Intenta nuevamente.');
      }
    } catch (e) {
      debugPrint('Error en el pago: $e');
      if (!mounted) return;
      _showErrorDialog('Ocurrió un error inesperado. Por favor, intenta nuevamente.');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
              child: const Icon(
                Icons.check,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Pago Exitoso!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            colors: [
              Colors.pink.shade50,
              Colors.white,
              Colors.purple.shade50,
            ],
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
                              onPressed: _isProcessing ? null : _restorePurchases,
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
                                  colors: [Colors.pinkAccent, Colors.purpleAccent],
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
                              _buildBenefitRow('🔥 Likes diarios', '30', 'Ilimitados', 0),
                              _buildDivider(),
                              _buildBenefitRow('💖 Ver a quién le gustas', '❌', '✅', 1),
                              _buildDivider(),
                              _buildBenefitRow('⏮️ Retroceder perfiles', '❌', '✅', 3),
                              _buildDivider(),
                              _buildBenefitRow('✍️ Editar perfil', '❌', '✅', 4),
                              _buildDivider(),
                              _buildBenefitRow('🙈 Alerta de match', '❌', '✅', 5),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            if (Platform.isIOS && _isLoadingIAP)
                              const CircularProgressIndicator(
                                color: Colors.pinkAccent,
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Platform.isIOS && _productPrice != null
                                        ? _productPrice!.substring(0, 1)
                                        : '\$',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                  Text(
                                    Platform.isIOS && _productPrice != null
                                        ? _productPrice!.substring(1)
                                        : '60 MXN',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      ' / semestre',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botón condicional basado en la plataforma
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
                                  : _handleIAPPurchase,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isProcessing)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isProcessing ? "Procesando..." : "Suscribirme",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
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
                              onTap: _isProcessing ? null : _handleStripePayment,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isProcessing)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isProcessing ? "Procesando..." : "Pagar con Stripe",
                                    style: const TextStyle(
                                      color: Colors.white,
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
                          CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                normal,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
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
}