import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/models/user_card.dart';

enum UserDetailSource { matches, likes, swiper }

class UserDetailPage extends StatefulWidget {
  final String userId;
  final UserDetailSource source;

  const UserDetailPage({super.key, required this.userId, required this.source});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserCard? user;
  bool loading = true;
  String? error;
  int currentPhotoIndex = 0;
  late PageController _pageController;

  bool get showInstagram {
    return widget.source == UserDetailSource.matches;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchUserDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchUserDetails() async {
    try {
      final res = await Supabase.instance.client
          .from('users')
          .select('''
            id_user,
            name,
            age,
            description,
            instagram_user,
      
            user_photos!left(url),
      
            genders(name),
            degrees(name),
            looking_for(name),
      
            user_has_life_habits(
              life_habits(name)
            )
          ''')
          .eq('id_user', widget.userId)
          .single();

      debugPrint('HABITS RAW -> ${res['user_has_life_habits']}');

      setState(() {
        user = UserCard.fromMap(res);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar la información del usuario';
        loading = false;
      });
      debugPrint('Error fetching user details: $e');
    }
  }

  Widget _buildPhotoIndicators() {
    if (user == null || user!.photos.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(
            user!.photos.length,
            (index) => Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: currentPhotoIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),

          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF424242),
        ),
      ),
    );
  }

  Widget _buildHabitItem(String habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B6B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
      );
    }

    if (error != null || user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            error ?? 'Usuario no encontrado',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.65,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      user!.photos.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: user!.photos.length,
                              onPageChanged: (index) {
                                setState(() => currentPhotoIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  user!.photos[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFFF6B6B),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.person,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.5, 1.0],
                            ),
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
                              '${user!.name}, ${user!.age}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 4,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            if (showInstagram && user!.instagramUser != null)
                              _buildInfoChip(
                                Icons.camera_alt_outlined,
                                'Instagram:',
                                '@${user!.instagramUser}',
                              ),
                          ],
                        ),
                      ),
                      _buildPhotoIndicators(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (user!.gender != null)
                            _buildInfoChip(
                              Icons.person_outline,
                              "Genero:",
                              user!.gender!,
                            ),
                          if (user!.degreeName != null)
                            _buildInfoChip(
                              Icons.school_outlined,
                              "Carrera:",
                              user!.degreeName!,
                            ),
                          if (user!.lookingFor != null)
                            _buildInfoChip(
                              Icons.favorite_border,
                              "En busca de:",
                              user!.lookingFor!,
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      if (user!.description != null &&
                          user!.description!.isNotEmpty) ...[
                        _buildSectionTitle('Sobre mí'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            user!.description!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      if (user!.habits.isNotEmpty) ...[
                        _buildSectionTitle('Estilo de vida'),
                        ...user!.habits.map((habit) => _buildHabitItem(habit)),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
