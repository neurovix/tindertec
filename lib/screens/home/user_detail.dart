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
  bool isPremium = false;

  bool get showInstagram {
    return widget.source == UserDetailSource.matches;
  }

  bool get showButtons {
    return widget.source == UserDetailSource.matches;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchUserDetails();
    _checkAuthAndLoad();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Future<void> _checkAuthAndLoad() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    await _checkPremium();
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
            custom_degree,
      
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

  void _showMatchDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(userName: userName),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  Future<void> _onLike(String likedUserId) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return;

    try {
      final alreadyLiked = await client
          .from('user_likes')
          .select('id_like')
          .eq('id_user_from', currentUser.id)
          .eq('id_user_to', likedUserId)
          .maybeSingle();

      if (alreadyLiked != null) {
        _showAlreadyLikedDialog(context);
        return;
      }

      // 🔢 PRIMERO validar límite (ANTES de guardar)
      if (!isPremium) {
        final canSwipe = await client.rpc(
          'check_and_add_swipe',
          params: {'p_user_id': currentUser.id},
        );

        final bool res = canSwipe == true;
        debugPrint('RPC RESULT: $res');

        if (canSwipe == false) {
          _showSwipeLimitDialog();
          if (mounted) _showSwipeLimitDialog();
          return; // ⛔ NO guarda el like
        }
      }

      // Insertar like
      await client.from('user_likes').upsert({
        'id_user_from': currentUser.id,
        'id_user_to': likedUserId,
      }, onConflict: 'id_user_from,id_user_to');

      // Intentar crear match vía RPC
      final result = await client.rpc(
        'create_match_if_mutual_like',
        params: {'p_user_a': currentUser.id, 'p_user_b': likedUserId},
      );

      // Si viene de likes y se creó un match, mostrar el modal
      if (widget.source == UserDetailSource.likes) {
        _showMatchDialog(context, user?.name ?? 'Usuario');
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error on like/match: $e');
    }
  }

  void _showSwipeLimitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('😔 Likes agotados'),
        content: const Text(
          'Tus likes diarios se han acabado.\n\n'
          'Vuélvete premium para likes ilimitados '
          'o espera hasta mañana.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium_details');
            },
            child: const Text('Hazte Premium'),
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
                                        if (loadingProgress == null) {
                                          return child;
                                        }
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

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!showButtons)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: 'dislike',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFFF6B6B),
                          size: 32,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: 'like',
                        onPressed: () {
                          _onLike(widget.userId);
                        },
                        backgroundColor: const Color(0xFFFF6B6B),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget del Modal de Match estilo Tinder
class MatchDialog extends StatefulWidget {
  final String userName;

  const MatchDialog({super.key, required this.userName});

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFF8E8E),
                  Color(0xFFFF6B6B),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFFFF6B6B),
                    size: 50,
                  ),
                ),

                const SizedBox(height: 25),

                // Texto "¡Es un Match!"
                const Text(
                  '¡Es un Match!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 15),

                // Texto con el nombre del usuario
                Text(
                  'Tú y ${widget.userName} se gustan mutuamente',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 30),

                // Botones
                Column(
                  children: [
                    // Botón "Enviar mensaje"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Aquí puedes navegar a la página de chat
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Text(
                            'Ahora podras ver su instagram en la pantalla de Matches',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón "Seguir descubriendo"
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Seguir descubriendo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
