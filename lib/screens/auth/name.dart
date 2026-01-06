import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = nameController.text.trim();
    final registerData = RegisterData(name: name);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: name.isEmpty
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      '/email',
                      arguments: registerData,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: name.isEmpty ? Colors.grey : Colors.black,
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
                onTap: () => Navigator.pop(context),
                child: Image.asset('assets/icons/back_arrow.png', height: 40),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Ahora tu nombre',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Ingresa tu nombre',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 10),

              const Text(
                'Así es como aparecerá en tu perfil',
                style: TextStyle(fontSize: 13),
              ),

              const Text(
                'No lo podrás cambiar después (solo PREMIUM)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
