import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/screens/home/user_detail.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  List<Map<String, dynamic>> matches = [];
  bool loading = true;

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return [];

    try {
      final res = await supabase
          .from('matches')
          .select('''
          id_user_1,
          id_user_2,
          matched_at,
          user1:users!matches_id_user_1_fkey (
            id_user,
            instagram_user,
            user_photos!left(url, is_main)
          ),
          user2:users!matches_id_user_2_fkey (
            id_user,
            instagram_user,
            user_photos!left(url, is_main)
          )
        ''')
          .or('id_user_1.eq.${currentUser.id},id_user_2.eq.${currentUser.id}')
          .order('matched_at', ascending: false);

      final List<Map<String, dynamic>> matchesList = [];

      for (final row in res) {
        final bool isUser1 = row['id_user_1'] == currentUser.id;
        final otherUser = isUser1 ? row['user2'] : row['user1'];

        if (otherUser == null) continue;

        final photos = (otherUser['user_photos'] as List<dynamic>? ?? []);
        final mainPhoto = photos.firstWhere(
          (p) => p['is_main'] == true,
          orElse: () => photos.isNotEmpty ? photos.first : null,
        );

        matchesList.add({
          'id_user': otherUser['id_user'],
          'instagram_user': otherUser['instagram_user'],
          'photo_url': mainPhoto?['url'],
        });
      }

      return matchesList;
    } catch (e) {
      debugPrint('❌ Error fetching matches: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      final data = await fetchMatches();
      if (mounted) {
        setState(() {
          matches = data;
          loading = false;
        });
      }
    } catch (e) {
      print('Error loading matches: $e');
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _openUserDetail(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserDetailPage(userId: userId, source: UserDetailSource.matches),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Image.asset('assets/images/logo_tindertec.png', height: 100),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes matches 😢',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'Aqui salen las personas que te han y haz dado like. Sus perfiles de instagram ahora estan disponibles',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      itemCount: matches.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.66,
                          ),
                      itemBuilder: (context, index) {
                        final user = matches[index];
                        return GestureDetector(
                          onTap: () => _openUserDetail(user['id_user']),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: user['photo_url'] != null
                                      ? Image.network(
                                          user['photo_url'],
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '@${user['instagram_user'] ?? 'unknown'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
