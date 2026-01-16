import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/models/user_card.dart';
import 'package:tindertec/screens/home/card_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CardSwiperController cardsController = CardSwiperController();

  final List<UserCard> _cards = [];
  int _offset = 0;

  bool _isFetching = false;
  bool _hasMoreUsers = true;
  bool isPremium = false;

  void _showAlreadyLikedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ups 😅'),
        content: const Text('Ya has dado like a este usuario'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    await _loadMoreUsers();
    await _checkPremium();
  }

  Future<void> _checkPremium() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res = await Supabase.instance.client
        .from('users')
        .select('is_premium')
        .eq('id_user', user.id)
        .single();

    setState(() {
      isPremium = res['is_premium'] ?? false;
    });
  }

  Future<List<UserCard>> fetchUsers({
    required String currentUserId,
    required int offset,
    int limit = 10,
  }) async {
    final res = await Supabase.instance.client.rpc(
      'get_swipe_users',
      params: {
        'p_user_id': currentUserId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return res.map<UserCard>((u) {
      return UserCard(
        id: u['id_user'],
        name: u['name'],
        age: u['age'],
        description: u['description'],
        degreeName: u['degree_name'],
        photos: u['photo_url'] != null ? [u['photo_url']] : [],
      );
    }).toList();
  }

  Future<void> _loadMoreUsers() async {
    if (_isFetching || !_hasMoreUsers) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isFetching = true;
    });

    final newUsers = await fetchUsers(currentUserId: user.id, offset: _offset);

    setState(() {
      if (newUsers.isEmpty) {
        _hasMoreUsers = false;
      } else {
        _cards.addAll(newUsers);
        _offset += newUsers.length;
      }
      _isFetching = false;
    });
  }

  Future<void> _onLike(UserCard likedUser) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return;

    try {
      final alreadyLiked = await client
          .from('user_likes')
          .select('id_like')
          .eq('id_user_from', currentUser.id)
          .eq('id_user_to', likedUser.id)
          .maybeSingle();

      // 🔥 CLAVE: verificar si el widget sigue montado
      if (!mounted) return;

      if (alreadyLiked != null) {
        _showAlreadyLikedDialog(context);
        return;
      }

      await client.from('user_likes').insert({
        'id_user_from': currentUser.id,
        'id_user_to': likedUser.id,
      });
    } catch (e) {
      debugPrint('❌ Error on like: $e');
    }
  }

  void _onDislike(UserCard user) {}

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (previousIndex < 0 || previousIndex >= _cards.length) {
      return false;
    }

    final swipedUser = _cards[previousIndex];

    if (direction == CardSwiperDirection.right) {
      _onLike(swipedUser);
    } else if (direction == CardSwiperDirection.left) {
      _onDislike(swipedUser);
    }

    if (_cards.length - previousIndex <= 3 && _hasMoreUsers && !_isFetching) {
      _loadMoreUsers();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty && !_hasMoreUsers) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Ya no hay más perfiles 😢',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Image.asset('assets/images/logo_tindertec.png', height: 100),
      ),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: cardsController,
              cardsCount: _cards.length,
              numberOfCardsDisplayed: _cards.length >= 3 ? 3 : _cards.length,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.all(24),
              onSwipe: _onSwipe,
              cardBuilder: (context, index, _, __) {
                if (index >= _cards.length) {
                  return const SizedBox.shrink();
                }
                return CardUser(user: _cards[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isPremium)
                  FloatingActionButton(
                    heroTag: 'undo',
                    onPressed: () => cardsController.undo(),
                    child: const Icon(Icons.arrow_back),
                  ),
                FloatingActionButton(
                  heroTag: 'dislike',
                  onPressed: () =>
                      cardsController.swipe(CardSwiperDirection.left),
                  child: const Icon(Icons.close),
                ),
                FloatingActionButton(
                  heroTag: 'like',
                  onPressed: () =>
                      cardsController.swipe(CardSwiperDirection.right),
                  child: const Icon(Icons.favorite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
