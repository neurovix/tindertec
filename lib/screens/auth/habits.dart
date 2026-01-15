import 'package:flutter/material.dart';
import 'package:tindertec/models/register_data.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final List<String> habits = [
    'Siempre escuchando música',
    'Gym',
    'Amigable',
    'Cafe lover',
    'Extrovertido',
    'Procrastinador',
    'Organizado',
    'Team nocturno',
    'Introvertido',
    'Fan del descanso',
    'Team madrugador',
    'Foráneo',
    'Todo el día en el tec',
    'Me quedo a actividades',
    'Ingeniero',
    'Busco ride',
    'Recursando',
    'Sin dinero',
    'Entro a todas las clases',
  ];

  final List<String> selectedHabits = [];

  void toggleHabit(String habit) {
    setState(() {
      if (selectedHabits.contains(habit)) {
        selectedHabits.remove(habit);
      } else {
        selectedHabits.add(habit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final RegisterData registerData = ModalRoute.of(context)!.settings.arguments as RegisterData;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: selectedHabits.length < 4
                ? null
                : () {
              registerData.habits = selectedHabits;
              Navigator.pushNamed(
                context,
                '/description',
                arguments: registerData,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedHabits.length < 4 ? Colors.grey : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Siguiente ${selectedHabits.length}/4',
              style: const TextStyle(
                fontSize: 18,
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
                child: const Icon(Icons.arrow_back, size: 28),
              ),
              const SizedBox(height: 30),
              const Text(
                'Hablemos sobre hábitos\nde tu estilo de vida',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selecciona mínimo 4',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: habits.map((habit) {
                      final bool isSelected = selectedHabits.contains(habit);
                      return GestureDetector(
                        onTap: () => toggleHabit(habit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            habit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}