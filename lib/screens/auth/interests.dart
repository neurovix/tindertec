import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  String? selectedInterest;

  @override
  Widget build(BuildContext context) {
    final RegisterData registerData = ModalRoute.of(context)!.settings.arguments as RegisterData;
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: selectedInterest == null
                ? null
                : () {
              registerData.interest = selectedInterest;
              Navigator.pushNamed(
                  context,
                  '/looking_for',
                  arguments: registerData
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              selectedInterest == null ? Colors.grey : Colors.black,
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
                '¿A quien te interesaria ver?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Selecciona todas las que apliquen para ayudarnos a recomendarte a las personas correctas.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              _interestOption('Hombres'),
              const SizedBox(height: 15),
              _interestOption('Mujeres'),
              const SizedBox(height: 15),
              _interestOption('Todxs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestOption(String value) {
    final bool isSelected = selectedInterest == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInterest = value;
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
