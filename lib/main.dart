import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tindertec/firebase_options.dart';
import 'package:tindertec/screens/auth/birthday.dart';
import 'package:tindertec/screens/auth/email.dart';
import 'package:tindertec/screens/auth/name.dart';
import 'package:tindertec/screens/auth/phone_number.dart';
import 'package:tindertec/screens/auth/text_welcome.dart';
import 'package:tindertec/screens/auth/verify_code.dart';
import 'screens/auth/welcome.dart';
import 'screens/auth/login.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/profile.dart';
import 'screens/home/matches.dart';
import 'screens/home/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/phone_number': (context) => const PhoneNumberScreen(),
        '/verify_code': (context) => const VerifyCodeScreen(),
        '/text_welcome': (context) => const TextWelcomeScreen(),
        '/name': (context) => const NameScreen(),
        '/birthday': (context) => const BirthdayScreen(),
        '/email': (context) => const EmailScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/matches': (context) => MatchesPage(),
        '/notifications': (context) => NotificationsPage(),
      },
    );
  }
}
