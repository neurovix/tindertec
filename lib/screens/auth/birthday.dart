import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tindertec/models/register_data.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  int selectedDay = 1;
  int selectedMonth = 1;
  int selectedYear = DateTime.now().year;

  final List<int> days = List.generate(31, (i) => i + 1);
  final List<int> months = List.generate(12, (i) => i + 1);
  final List<int> years =
  List.generate(60, (i) => DateTime.now().year - i);

  int age = 1;

  @override
  void initState() {
    super.initState();
    calculateAge();
  }

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
            onPressed: age >= 18
                ? () {
              registerData.age = age;
              Navigator.pushNamed(
                context,
                '/degree',
                arguments: registerData,
              );
            }
                : () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edad insuficiente'),
                  content: const Text(
                    'Debes ser mayor de 18 años para utilizar esta aplicación.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: age >= 18 ? Colors.black : Colors.grey,
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

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  '¿Tu cumpleaños?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    _buildPicker(
                      items: days,
                      initialIndex: selectedDay - 1,
                      onChanged: (index) {
                        setState(() {
                          selectedDay = days[index];
                        });
                        calculateAge();
                      },
                      label: 'DD',
                    ),

                    _separator(),

                    _buildPicker(
                      items: months,
                      initialIndex: selectedMonth - 1,
                      onChanged: (index) {
                        setState(() {
                          selectedMonth = months[index];
                        });
                        calculateAge();
                      },
                      label: 'MM',
                    ),

                    _separator(),

                    _buildPicker(
                      items: years,
                      initialIndex: 0,
                      onChanged: (index) {
                        setState(() {
                          selectedYear = years[index];
                        });
                        calculateAge();
                      },
                      label: 'YYYY',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Tu perfil muestra tu edad, no tu fecha de nacimiento',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    if (age < 18)
                      const Text(
                        'Debes ser mayor de 18 años',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void calculateAge() {
    final DateTime today = DateTime.now();
    final DateTime birthday =
    DateTime(selectedYear, selectedMonth, selectedDay);

    int years = today.year - birthday.year;

    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      years--;
    }

    setState(() {
      age = years;
    });
  }


  Widget _buildPicker({
    required List<int> items,
    required int initialIndex,
    required Function(int) onChanged,
    required String label,
  }) {
    return Expanded(
      child: CupertinoPicker(
        scrollController:
        FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Colors.transparent,
        ),
        children: items
            .map(
              (e) => Center(
            child: Text(
              e.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '/',
        style: TextStyle(fontSize: 26),
      ),
    );
  }
}
