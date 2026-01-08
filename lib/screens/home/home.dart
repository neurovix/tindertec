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

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 HomePage initState');
    _loadMoreUsers();
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

    _isFetching = true;

    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('👤 Current auth user: ${currentUser?.id}');

    if (currentUser == null) {
      debugPrint('❌ No authenticated user');
      _isFetching = false;
      return;
    }

    final newUsers = await fetchUsers(
      currentUserId: currentUser.id,
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

  Future<void> _onSwipe(int index) async {
    debugPrint('➡️ Swipe detected at index: $index');
    _currentIndex++;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('❌ Swipe but no auth user');
      return;
    }

    debugPrint('📝 Saving swipe for user: ${currentUser.id}');
    await Supabase.instance.client.from('user_swipes').insert({
      'id_user': currentUser.id,
    });

    debugPrint('📊 Total swipes: $_currentIndex');

    final swipedUser = _cards[index];
    debugPrint('❤️ Liked user: ${swipedUser.id}');

    await Supabase.instance.client.from('user_likes').insert({
      'id_user_from': currentUser.id,
      'id_user_to': swipedUser.id,
    });

    if (_currentIndex % 7 == 0) {
      debugPrint('🔄 7 swipes reached, loading more users');
      _loadMoreUsers();
    }
  }

  Future<void> _onLike(int index) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final likedUser = _cards[index];

    debugPrint('❤️ Liking user: ${likedUser.id}');

    await Supabase.instance.client.from('user_likes').insert({
      'id_user_from': currentUser.id,
      'id_user_to': likedUser.id,
    });

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
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 build() called | cards: ${_cards.length}');

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
                  _onLike(prev); // ❤️
                } else {
                  _onDislike(prev); // ❌
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
