import 'package:flutter/material.dart';
import 'package:tindertec/models/user_card.dart';
import 'package:tindertec/screens/home/user_detail.dart';

class CardUser extends StatelessWidget {
  final UserCard user;

  const CardUser({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('🟢 Card tapped: ${user.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailPage(user: user),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            user.photos.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                user.photos.first,
                fit: BoxFit.cover,
              ),
            )
                : Container(color: Colors.grey),

            // GRADIENT
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent
                  ],
                ),
              ),
            ),

            // INFO
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                '${user.name}, ${user.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
