import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tindertec/firebase_options.dart';
import 'screens/auth/welcome.dart';
import 'screens/auth/login.dart';
import 'screens/auth/signin.dart';
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
      title: 'TINDERTEC 💘',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/matches': (context) => MatchesPage(),
        '/notifications': (context) => NotificationsPage(),
      },
    );
  }
}
