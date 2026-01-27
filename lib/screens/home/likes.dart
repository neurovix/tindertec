import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/screens/home/user_detail.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool isPremium = false;
  String? error;

  List<Map<String, dynamic>> likesUsers = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _openUserDetail(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserDetailPage(userId: userId, source: UserDetailSource.likes),
      ),
    );
  }

  Future<void> _init() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final userRes = await supabase
          .from('users')
          .select('is_premium')
          .eq('id_user', userId)
          .single();

      isPremium = userRes['is_premium'] == true;

      if (isPremium) {
        final likesRes = await supabase.rpc(
          'get_incoming_likes_no_match',
          params: {'p_user_id': userId},
        );

        likesUsers = List<Map<String, dynamic>>.from(likesRes);
      }
    } catch (e) {
      error = 'Error al cargar likes';
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (!isPremium) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          centerTitle: true,
          title: Image.asset('assets/images/logo_tindertec.png', height: 100),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Tienes que ser premium para ver a qué personas le gustaste',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Image.asset('assets/images/logo_tindertec.png', height: 100),
      ),
      body: likesUsers.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes likes',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'Aqui salen las personas que te han dado like',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: likesUsers.length,
                      itemBuilder: (context, index) {
                        final user = likesUsers[index];
                        final photos = user['user_photos'] as List<dynamic>;

                        final photoUrl = photos.isNotEmpty
                            ? photos.first['url']
                            : null;

                        return _LikeCard(
                          userId: user['id_user'],
                          name: user['name'],
                          photoUrl: photoUrl,
                          onTap: () => _openUserDetail(user['id_user']),
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

class _LikeCard extends StatelessWidget {
  final String userId;
  final String name;
  final String? photoUrl;
  final VoidCallback onTap;

  const _LikeCard({
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            photoUrl != null
                ? Image.network(photoUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
