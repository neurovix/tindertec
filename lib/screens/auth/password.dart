import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/models/register_data.dart';
import 'package:tindertec/services/auth_service.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final password = passwordController.text.trim();
    final RegisterData registerData = ModalRoute.of(context)!.settings.arguments as RegisterData;
    print(registerData.name);
    print(registerData.email);
    print(registerData.gender);
    print(registerData.age);
    print(registerData.degree);
    print(registerData.interest);
    print(registerData.lookingFor);
    print(registerData.habits);
    print(registerData.description);
    print(registerData.photos);
    print(registerData.instagramUser);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
              password.isEmpty ? null
              : () {
                void handleSupabaseRegister() async {
                  try {
                    await authService.signUpWithEmailAndPassword(registerData.email!, password);
                    // Registrar informacion de usuario
                    Supabase.instance.client.from("public.users").insert({
                      'name': registerData.name,
                      'age': registerData.age,
                      'description': registerData.description,
                      'instagram_user': registerData.instagramUser,
                      'profile_completed': true,
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                }

                Navigator.pushNamed(context, '/become_premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: password.isEmpty ? Colors.grey : Colors.black,
            ),
            child: const Text(
              'Crear cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  height: 40,
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Ahora tu contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ingresa tu contraseña',
                ),
                controller: passwordController,
                onChanged: (_) {
                  setState(() {});
                }
              ),

              const SizedBox(height: 20),

              const Text(
                'Asegurate de ingresar bien tu contraseña, ya que no podras cambiarla en el futuro'
              ),
            ],
          ),
        ),
      ),
    );
  }
}
