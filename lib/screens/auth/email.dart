import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = emailController.text.trim();
    final RegisterData registerData =
        ModalRoute.of(context)!.settings.arguments as RegisterData;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: email.isEmpty
                ? null
                : () {
                    registerData.email = email;
                    Navigator.pushNamed(
                        context,
                        '/gender',
                        arguments: registerData
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: email.isEmpty ? Colors.grey : Colors.black,
            ),
            child: const Text(
              'Siguiente',
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
                child: Image.asset('assets/icons/back_arrow.png', height: 40),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Ahora tu correo electronico',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Correo electronico'),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Asegurate de ingresar correctamente tu correo electronico, ya que no podra ser cambiado mas adelante',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
