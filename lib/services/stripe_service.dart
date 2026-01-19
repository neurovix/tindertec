import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

enum ApiServiceMethodType {
  get,
  post,
}

class StripeService {
  static String _stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY']!;
  static const baseUrl = 'https://api.stripe.com/v1';

  static Map<String, String> get requestHeaders => {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': 'Bearer $_stripeSecretKey',
  };

  // Crear un cliente de Stripe
  static Future<Map<String, dynamic>?> createCustomer(String email) async {
    try {
      final response = await apiService(
        endpoint: 'customers',
        requestMethod: ApiServiceMethodType.post,
        requestBody: {
          'email': email,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error creating customer: $e');
      return null;
    }
  }

  // Crear un Payment Intent para pago único
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount, // en centavos (ej: 6000 para $60 MXN)
    required String currency,
    String? customerId,
  }) async {
    try {
      final body = {
        'amount': amount.toString(),
        'currency': currency,
      };

      if (customerId != null) {
        body['customer'] = customerId;
      }

      final response = await apiService(
        endpoint: 'payment_intents',
        requestMethod: ApiServiceMethodType.post,
        requestBody: body,
      );
      return response;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  // Crear una suscripción
  static Future<Map<String, dynamic>?> createSubscription(
      String customerId,
      String priceId,
      String paymentMethodId,
      ) async {
    try {
      final response = await apiService(
        endpoint: 'subscriptions',
        requestMethod: ApiServiceMethodType.post,
        requestBody: {
          'customer': customerId,
          'items[0][price]': priceId,
          'default_payment_method': paymentMethodId,
          'expand[0]': 'latest_invoice.payment_intent',
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return null;
    }
  }

  // Inicializar el Payment Sheet para pago único
  static Future<bool> initPaymentSheet({
    required String paymentIntentClientSecret,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          primaryButtonLabel: 'Pagar',
          style: ThemeMode.light,
          merchantDisplayName: 'Tu App Premium',
          paymentIntentClientSecret: paymentIntentClientSecret,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "MX",
            testEnv: true, // Cambia a false en producción
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      return false;
    }
  }

  // Presentar el Payment Sheet
  static Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      if (e is StripeException) {
        debugPrint('Error from Stripe: ${e.error.localizedMessage}');
      } else {
        debugPrint('Unforeseen error: $e');
      }
      return false;
    }
  }

  // Servicio API genérico
  static Future<Map<String, dynamic>?> apiService({
    required ApiServiceMethodType requestMethod,
    required String endpoint,
    Map<String, dynamic>? requestBody,
  }) async {
    final requestUrl = '$baseUrl/$endpoint';

    try {
      http.Response requestResponse;

      if (requestMethod == ApiServiceMethodType.get) {
        requestResponse = await http.get(
          Uri.parse(requestUrl),
          headers: requestHeaders,
        );
      } else {
        requestResponse = await http.post(
          Uri.parse(requestUrl),
          headers: requestHeaders,
          body: requestBody,
        );
      }

      if (requestResponse.statusCode == 200 || requestResponse.statusCode == 201) {
        return json.decode(requestResponse.body);
      } else {
        debugPrint('API Error: ${requestResponse.statusCode} - ${requestResponse.body}');
        return null;
      }
    } catch (err) {
      debugPrint("${requestMethod.name.toUpperCase()} Error: $err");
      return null;
    }
  }

  // Método completo para procesar un pago único
  static Future<bool> processPayment({
    required int amount,
    required String currency,
    required BuildContext context,
    String? userEmail,
  }) async {
    try {
      // 1. Crear Payment Intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      if (paymentIntent == null) {
        throw Exception('No se pudo crear el Payment Intent');
      }

      final clientSecret = paymentIntent['client_secret'];

      // 2. Inicializar Payment Sheet
      final initialized = await initPaymentSheet(
        paymentIntentClientSecret: clientSecret,
      );

      if (!initialized) {
        throw Exception('No se pudo inicializar el Payment Sheet');
      }

      // 3. Presentar Payment Sheet
      final success = await presentPaymentSheet();

      return success;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return false;
    }
  }
}
