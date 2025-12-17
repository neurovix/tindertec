import 'package:flutter/material.dart';

class TextWelcomeScreen extends StatefulWidget {
  const TextWelcomeScreen({super.key});

  @override
  State<TextWelcomeScreen> createState() => _TextWelcomeScreen();
}

class _TextWelcomeScreen extends State<TextWelcomeScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 40),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/name');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
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
          padding: const EdgeInsets.all(20.0),
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
                  'Te damos la bienvenida a TINDERTEC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Por favor, sigue estas normas',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'No finjas ser alguien mas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Asegurate de que tus fotos, edad y biografia correspondan con quien eres actualmente.',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Cuidate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'No des tu informacion personal demasiado pronto.',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Tomalo con calma',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Respeta a las demas personas y tratalas como te gustaria que te trataran.',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Toma la iniciativa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Siempre denuncia el mal comportamiento.',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
