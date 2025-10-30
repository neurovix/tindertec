import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomePage extends StatelessWidget {
  final CardSwiperController cardsController = CardSwiperController();

  final List<Map<String, dynamic>> users = [
    {
      "id": "1",
      "sex": "female",
      "name": "Sydney Sweeney",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/sydney_sweeney.png",
    },
    {
      "id": "2",
      "sex": "female",
      "name": "Camila Sodi",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/camila_sodi.webp",
    },
    {
      "id": "3",
      "sex": "female",
      "name": "Margot Robbie",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/margot_robbie.webp",
    },
    {
      "id": "4",
      "sex": "female",
      "name": "Megan Fox",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/megan_fox.webp",
    },
    {
      "id": "5",
      "sex": "female",
      "name": "Sofia Vergara",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/sofia_vergara.avif",
    },
    {
      "id": "6",
      "sex": "female",
      "name": "Beth Cast",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/beth_cast.jpg",
    },
    {
      "id": "7",
      "sex": "female",
      "name": "Sabrina Carpenter",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/sabrina_carpenter.webp",
    },
    {
      "id": "8",
      "sex": "female",
      "name": "Salma Hayek",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/salma_hayek.jpg",
    },
    {
      "id": "9",
      "sex": "female",
      "name": "Rey Skywalker",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/rey_star_wars.webp",
    },
    {
      "id": "10",
      "sex": "female",
      "name": "Natalie Portman",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/natalie_portman.jpg",
    },
    {
      "id": "11",
      "sex": "male",
      "name": "Carlos Slim",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/carlos_slim.jpg",
    },
    {
      "id": "12",
      "sex": "male",
      "name": "Eminem",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/eminem.jpg",
    },
    {
      "id": "13",
      "sex": "male",
      "name": "Omar Chaparro",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/omar_chaparro.jpg",
    },
    {
      "id": "14",
      "sex": "male",
      "name": "Eugenio Derbez",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/eugenio_derbez.jpg",
    },
    {
      "id": "15",
      "sex": "male",
      "name": "Albertano",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/albertano.jpg",
    },
    {
      "id": "16",
      "sex": "male",
      "name": "Adrian Uribe",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/adrian_uribe.gif",
    },
    {
      "id": "17",
      "sex": "male",
      "name": "Adal Ramones",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/adal_ramones.jpg",
    },
    {
      "id": "18",
      "sex": "male",
      "name": "Bradley Cooper",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/bradley_cooper.webp",
    },
    {
      "id": "19",
      "sex": "male",
      "name": "Will Smith",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/will_smith.jpg",
    },
    {
      "id": "20",
      "sex": "male",
      "name": "Ariel Camacho",
      "description": "lorem impsum lorem ipsum lorem lorem ipsum lorem lorem",
      "photo_url":
          "https://xzeeudfqafydqizuqorm.supabase.co/storage/v1/object/public/lotes/ariel_camacho.jpg",
    },
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                controller: cardsController,
                cardsCount: users.length,
                onSwipe: _onSwipe,
                onUndo: _onUndo,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(40, 40),
                padding: const EdgeInsets.all(24.0),
                cardBuilder:
                    (
                      context,
                      index,
                      horizontalThresholdPercentage,
                      verticalThresholdPercentage,
                    ) {
                      final user = users[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        elevation: 8,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(user["photo_url"], fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user["name"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user["description"],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: cardsController.undo,
                    child: Image.asset(
                        'assets/icons/return.png',
                        height: 200
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () =>
                        cardsController.swipe(CardSwiperDirection.left),
                    child: Image.asset(
                      'assets/icons/dislike.png',
                      height: 200
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () =>
                        cardsController.swipe(CardSwiperDirection.right),
                    child: Image.asset(
                      'assets/icons/like.png',
                      height: 200
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

bool _onSwipe(
  int previousIndex,
  int? currentIndex,
  CardSwiperDirection direction,
) {
  debugPrint(
    'The card $previousIndex was swiped to ${direction.name}. Now the card $currentIndex is on top',
  );
  return true;
}

bool _onUndo(
  int? previousIndex,
  int currentIndex,
  CardSwiperDirection direction,
) {
  debugPrint('The card $currentIndex was undod from the ${direction.name}');
  return true;
}
