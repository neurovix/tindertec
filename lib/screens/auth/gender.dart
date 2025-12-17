import 'package:flutter/material.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: selectedGender == null
                ? null
                : () {
              Navigator.pushNamed(context, '/interests');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              selectedGender == null ? Colors.grey : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 30),
              ),

              const SizedBox(height: 30),

              const Text(
                '¿Cuál es tu género?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Selecciona todo lo que te describa para ayudarte a mostrar tu perfil a las personas correctas.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              _genderOption('Hombre'),
              const SizedBox(height: 15),
              _genderOption('Mujer'),
              const SizedBox(height: 15),
              _genderOption('Otro / Prefiero no decirlo'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderOption(String value) {
    final bool isSelected = selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
