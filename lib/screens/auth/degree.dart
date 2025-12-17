import 'package:flutter/material.dart';

class DegreeScreen extends StatefulWidget {
  const DegreeScreen({super.key});

  @override
  State<DegreeScreen> createState() => _DegreeScreenState();
}

class _DegreeScreenState extends State<DegreeScreen> {
  String? selectedDegree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: selectedDegree == null
                ? null
                : () {
                    Navigator.pushNamed(context, '/photos');
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedDegree == null
                  ? Colors.grey
                  : Colors.black,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 30),
                ),

                const SizedBox(height: 30),

                const Text(
                  '¿En que carrera estas?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Ayudanos diciendo en que carrera estas, asi sera mas facil recomendarte a otras personas.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                _degreeOption('Ingenieria en Sistemas Computacionales'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria electrica'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria electronica'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria Industrial'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria Mecanica'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria Mecatronica'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria Materiales'),
                const SizedBox(height: 15),
                _degreeOption('Ingenieria en Gestion Empresarial'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _degreeOption(String value) {
    final bool isSelected = selectedDegree == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDegree = value;
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
