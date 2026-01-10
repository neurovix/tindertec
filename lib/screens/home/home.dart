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
  int _currentIndex = 0;
  int _offset = 0;
  bool _isFetching = false;
  bool _hasMoreUsers = true;
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 HomePage initState');
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No hay usuario autenticado. Redirigiendo a login.');
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }
    await _loadMoreUsers();
    await isUserPremium();
  }

  Future<void> isUserPremium() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user para premium check');
      isPremium = false;
      setState(() {});
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from("users")
          .select('is_premium')
          .eq('id_user', user.id)
          .single();
      isPremium = res['is_premium'] as bool? ?? false;
      debugPrint('👑 User premium: $isPremium');
      setState(() {});
    } catch (e) {
      debugPrint('❌ Error checking premium: $e');
      isPremium = false;
      setState(() {});
    }
  }

  Future<List<UserCard>> fetchUsers({
    required String currentUserId,
    required int offset,
    int limit = 10,
  }) async {
    debugPrint('🟡 fetchUsers()');
    debugPrint('➡️ currentUserId: $currentUserId');
    debugPrint('➡️ offset: $offset | limit: $limit');

    final res = await Supabase.instance.client
        .from('users')
        .select('''
          id_user,
          name,
          age,
          description,
          degrees!inner(name),
          user_photos!left(url)
        ''')
        .eq('profile_completed', true)
        .neq('id_user', currentUserId)
        .eq('user_photos.is_main', true)
        .order('created_at')
        .range(offset, offset + limit - 1);

    debugPrint('🟢 Raw response from Supabase:');
    debugPrint(res.toString());

    final users = res.map<UserCard>((u) {
      debugPrint('🧩 Mapping user: $u');
      return UserCard.fromMap(u);
    }).toList();

    debugPrint('✅ Users parsed: ${users.length}');
    return users;
  }

  Future<void> _loadMoreUsers() async {
    debugPrint('🔵 _loadMoreUsers() called');
    if (_isFetching) {
      debugPrint('⏸️ Already fetching, skipping');
      return;
    }
    if (!_hasMoreUsers) {
      debugPrint('🚫 No more users to fetch');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No authenticated user');
      _isFetching = false;
      Navigator.pushNamed(context, '/welcome');
      return;
    }

    _isFetching = true;
    debugPrint('👤 Current auth user: ${user.id}');

    final newUsers = await fetchUsers(
      currentUserId: user.id,
      offset: _offset,
    );

    if (newUsers.isEmpty) {
      debugPrint('⚠️ No users returned from DB');
      _hasMoreUsers = false;
    } else {
      debugPrint('➕ Adding ${newUsers.length} users to cards');
      _cards.addAll(newUsers);
      _offset += newUsers.length;
      debugPrint('📦 Total cards now: ${_cards.length}');
    }

    _isFetching = false;
    setState(() {});
  }

  Future<void> _onLike(int index) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No auth user for like');
      return;
    }

    final likedUser = _cards[index];
    debugPrint('❤️ Liking user: ${likedUser.id}');
    try {
      await Supabase.instance.client.from('user_likes').insert({
        'id_user_from': user.id,
        'id_user_to': likedUser.id,
      });
    } catch (e) {
      debugPrint('❌ Error inserting like: $e');
    }
    _afterSwipe();
  }

  void _onDislike(int index) {
    debugPrint('❌ Disliked user: ${_cards[index].id}');
    _afterSwipe();
  }

  void _afterSwipe() {
    _currentIndex++;
    if (_currentIndex % 7 == 0) {
      debugPrint('🔄 7 swipes reached, loading more users');
      _loadMoreUsers();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 build() called | cards: ${_cards.length}');

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No auth in build, showing login prompt');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Por favor, inicia sesión para continuar.'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                child: const Text('Ir a Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasMoreUsers && _currentIndex >= _cards.length) {
      debugPrint('🏁 No more users to show');
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
      debugPrint('⏳ Cards empty, showing loader');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_tindertec.png',
          height: 100,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: cardsController,
              cardsCount: _cards.length,
              onSwipe: (prev, current, direction) {
                debugPrint(
                  '➡️ onSwipe | prev: $prev | current: $current | dir: ${direction.name}',
                );
                if (direction == CardSwiperDirection.right) {
                  _onLike(prev);
                } else {
                  _onDislike(prev);
                }
                return true;
              },
              numberOfCardsDisplayed: 3,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.all(24),
              cardBuilder: (context, index, _, __) {
                debugPrint('🃏 Building card at index: $index');
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
                    onPressed: () {
                      debugPrint('↩️ Undo');
                      cardsController.undo();
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                FloatingActionButton(
                  heroTag: 'dislike',
                  onPressed: () {
                    debugPrint('👎 Dislike pressed');
                    cardsController.swipe(CardSwiperDirection.left);
                  },
                  child: const Icon(Icons.close),
                ),
                FloatingActionButton(
                  heroTag: 'like',
                  onPressed: () {
                    debugPrint('❤️ Like pressed');
                    cardsController.swipe(CardSwiperDirection.right);
                  },
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
