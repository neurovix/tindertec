import 'package:flutter/material.dart';
import 'package:tindertec/screens/home/user_detail.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final List<Map<String, dynamic>> matches = [
    {
      'name': 'Andrea',
      'photo_url': 'https://picsum.photos/400/600?1',
      'description': 'Ingeniería en Sistemas'
    },
    {
      'name': 'Luis',
      'photo_url': 'https://picsum.photos/400/600?2',
      'description': 'Industrial'
    },
    {
      'name': 'María',
      'photo_url': 'https://picsum.photos/400/600?3',
      'description': 'Mecatrónica'
    },
    {
      'name': 'Carlos',
      'photo_url': 'https://picsum.photos/400/600?4',
      'description': 'Electrónica'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_tindertec.png',
          height: 100,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aqui salen las personas que te han y haz dado like. Sus perfiles de instagram ahora estan disponibles',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: matches.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final user = matches[index];
                  return GestureDetector(
                    onTap: () {
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailPage(user: user),
                        ),
                      );
                      */
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              user['photo_url'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
