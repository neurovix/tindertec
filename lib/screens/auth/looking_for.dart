import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class LookingForScreen extends StatefulWidget {
  const LookingForScreen({super.key});

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  String? selectedInterest;

  final List<Map<String, String>> interests = [
    {
      'label': 'Relacion seria',
      'image': 'assets/icons/relationship.png',
    },
    {
      'label': 'Diversion / Corto plazo',
      'image': 'assets/icons/party.png',
    },
    {
      'label': 'Hacer tarea juntos',
      'image': 'assets/icons/study.png',
    },
    {
      'label': 'Contactos / Negocios',
      'image': 'assets/icons/handshake.png',
    },
    {
      'label': 'Amigos',
      'image': 'assets/icons/hi.png',
    },
    {
      'label': 'Lo sigo pensando',
      'image': 'assets/icons/confused.png',
    },
  ];

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
              registerData.lookingFor = selectedInterest;
              Navigator.pushNamed(
                  context,
                  '/habits',
                  arguments: registerData,
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
                '¿Que estas buscando?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Todo esta bien, si cambia hay para todos.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth =
                      (constraints.maxWidth - 20) / 3;

                  return Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: interests.map((item) {
                      return _interestOption(
                        item['label']!,
                        item['image']!,
                        itemWidth,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestOption(
      String value,
      String imagePath,
      double width,
      ) {
    final bool isSelected = selectedInterest == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInterest = value;
        });
      },
      child: SizedBox(
        width: width,
        child: Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
