import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class DescriptionScreen extends StatefulWidget {
  const DescriptionScreen({super.key});

  @override
  State<DescriptionScreen> createState() => _DescriptionState();
}

class _DescriptionState extends State<DescriptionScreen> {
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = descriptionController.text.trim();
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
            onPressed: description.isEmpty
                ? null
                : () {
              registerData.description = description;
              Navigator.pushNamed(
                  context,
                  '/photos',
                  arguments: registerData,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              description.isEmpty ? Colors.grey : Colors.black,
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
                  'Ahora tu descripcion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 4,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Ingresa tu descripción',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 10),

              const Text(
                'Asi es como aparecera en tu perfil',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              const Text(
                'No lo podras cambiar despues (Solamente si eres PREMIUM)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
