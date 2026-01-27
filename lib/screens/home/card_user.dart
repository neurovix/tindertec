import 'package:flutter/material.dart';
import 'package:tindertec/models/user_card.dart';
import 'package:tindertec/screens/home/user_detail.dart';

class CardUser extends StatelessWidget {
  final UserCard user;

  const CardUser({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textShadow = [
      Shadow(
        offset: const Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Colors.black87,
      ),
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailPage(
              userId: user.id,
              source: UserDetailSource.swiper,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            user.photos.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(user.photos.first, fit: BoxFit.cover),
                  )
                : Container(color: Colors.grey),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name}, ${user.age}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: textShadow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.degreeName.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      shadows: textShadow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
