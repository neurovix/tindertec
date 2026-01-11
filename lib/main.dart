import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/screens/auth/become_premium.dart';
import 'package:tindertec/screens/auth/description.dart';
import 'package:tindertec/screens/auth/password.dart';
import 'package:tindertec/screens/auth/photos.dart';
import 'package:tindertec/screens/auth/welcome.dart';
import 'package:tindertec/screens/auth/login.dart';
import 'package:tindertec/screens/auth/instagram.dart';
import 'package:tindertec/screens/auth/text_welcome.dart';
import 'package:tindertec/screens/auth/name.dart';
import 'package:tindertec/screens/auth/birthday.dart';
import 'package:tindertec/screens/auth/gender.dart';
import 'package:tindertec/screens/auth/interests.dart';
import 'package:tindertec/screens/auth/looking_for.dart';
import 'package:tindertec/screens/auth/habits.dart';
import 'package:tindertec/screens/auth/degree.dart';
import 'package:tindertec/screens/auth/email.dart';
import 'package:tindertec/screens/home/home_screen.dart';
import 'package:tindertec/screens/home/premium_details.dart';
import 'package:tindertec/screens/home/profile.dart';
import 'package:tindertec/screens/home/matches.dart';
import 'package:tindertec/screens/home/likes.dart';
import 'package:tindertec/services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!
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
      home: const AuthGate(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/instagram': (context) => const InstagramScreen(),
        '/text_welcome': (context) => const TextWelcomeScreen(),
        '/name': (context) => const NameScreen(),
        '/birthday': (context) => const BirthdayScreen(),
        '/gender': (context) => const GenderScreen(),
        '/interests': (context) => const InterestsScreen(),
        '/looking_for': (context) => const LookingForScreen(),
        '/habits': (context) => const HabitsScreen(),
        '/degree': (context) => const DegreeScreen(),
        '/photos': (context) => const PhotoScreen(),
        '/password': (context) => const PasswordScreen(),
        '/become_premium': (context) => const BecomePremiumScreen(),
        '/description': (context) => const DescriptionScreen(),
        '/email': (context) => const EmailScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/matches': (context) => MatchesPage(),
        '/likes': (context) => const LikesScreen(),
        '/premium_details': (context) => const PremiumDetailsScreen(),
      },
    );
  }
}
