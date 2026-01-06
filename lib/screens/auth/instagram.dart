import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class InstagramScreen extends StatefulWidget {
  const InstagramScreen({super.key});

  @override
  State<InstagramScreen> createState() => _InstagramState();
}

class _InstagramState extends State<InstagramScreen> {
  final TextEditingController instagramController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String instagram = instagramController.text.trim();
    final RegisterData registerData = ModalRoute.of(context)!.settings.arguments as RegisterData;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              instagram.isEmpty ? null :
              registerData.instagramUser = instagram;
              Navigator.pushNamed(
                  context,
                  '/password',
                  arguments: registerData
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: instagram.isEmpty ? Colors.grey : Colors.black,
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
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  height: 40,
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  '¿Puedes darnos tu usuario de instagram?',
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
                decoration: InputDecoration(
                  labelText: 'Ingresa tu usuario de instagram',
                ),
                controller: instagramController,
                onChanged: (_) {
                  setState(() {});
                }
              ),

              const SizedBox(height: 40),

              const Text(
                'Tu usuario de instagram se mostrara solamente cuando tu y la otra persona hagan match, para que puedan continuar con la conversacion desde fuera, si alguien te da like y tu no respondes con la misma accion, tu instagram no sera visible para la otra persona.',
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
