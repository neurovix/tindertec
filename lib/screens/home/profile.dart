import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String selectedGender = "";
  String selectedCarrera = '';
  String selectedInterest = '';
  String name = '';
  String age = '';
  String description = '';
  String instagram = '';
  bool isPremium = false;
  String userProfileUrl = "";

  late AnimationController _animationController;

  Future<void> getUserInformation() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final data = await Supabase.instance.client
          .from('users')
          .select('''
            name,
            age,
            description,
            instagram_user,
            id_gender,
            id_degree,
            id_interest,
            is_premium,
            user_photos!inner(
              url,
              is_main
            )
          ''')
          .eq('id_user', user.id)
          .eq('user_photos.is_main', true)
          .single();

      final photos = data['user_photos'] as List;

      final String? photoUrl = photos.isNotEmpty
          ? photos.first['url'] as String
          : null;

      setState(() {
        name = data['name'] ?? '';
        age = '${data['age']} años';
        description = data['description'] ?? '';
        instagram = data['instagram_user'] ?? '';

        selectedGender = data['id_gender'].toString();
        selectedCarrera = data['id_degree'].toString();
        selectedInterest = data['id_interest'].toString();

        isPremium = data['is_premium'] as bool? ?? false;
        userProfileUrl = photoUrl ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando perfil: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    getUserInformation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Eliminar cuenta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Esta acción es permanente y eliminará toda tu información. '
            '¿Estás seguro de que deseas continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // cerrar modal
                await _deleteAccount(); // eliminar
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String value) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión no válida, vuelve a iniciar sesión'),
        ),
      );
      return;
    }

    try {
      final res = await client
          .from('users')
          .update({'name': value})
          .eq('id_user', user.id)
          .select();

      if (res.isEmpty) {
        throw Exception('Update blocked by RLS');
      }
    } catch (e) {
      debugPrint('❌ Error updating name: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar descripción, intenta más tarde'),
        ),
      );
    }
  }

  Future<void> _updateUserDescription(String value) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión no válida, vuelve a iniciar sesión'),
        ),
      );
      return;
    }

    try {
      final res = await client
          .from('users')
          .update({'description': value})
          .eq('id_user', user.id)
          .select();

      if (res.isEmpty) {
        throw Exception('Update blocked by RLS');
      }
    } catch (e) {
      debugPrint('❌ Error updating description: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar descripción, intenta más tarde'),
        ),
      );
    }
  }

  Future<void> _updateUserInstagram(String value) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión no válida, vuelve a iniciar sesión'),
        ),
      );
      return;
    }

    try {
      final res = await client
          .from('users')
          .update({'instagram_user': value})
          .eq('id_user', user.id)
          .select();

      if (res.isEmpty) {
        throw Exception('Update blocked by RLS');
      }
    } catch (e) {
      debugPrint('❌ Error updating instagram: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar descripción, intenta más tarde'),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await Supabase.instance.client.rpc(
        'delete_user_account',
        params: {'p_user_id': Supabase.instance.client.auth.currentUser!.id},
      );

      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al eliminar cuenta: $e")));
      debugPrint("Error: $e");
    }
  }

  Future<void> _showEditDialog({
    required String label,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Ingrese $label'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Actualizar'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getGender(String value) {
    switch (value) {
      case "1":
        return "Hombre";
      case "2":
        return "Mujer";
      default:
        return "Prefiero no decirlo";
    }
  }

  String getDegree(String value) {
    switch (value) {
      case "1":
        return "Ingenieria en Sistemas Computacionales";
      case "2":
        return "Ingenieria Electrica";
      case "3":
        return "Ingenieria Electronica";
      case "4":
        return "Ingenieria Industrial";
      case "5":
        return "Ingenieria Mecanica";
      case "6":
        return "Ingenieria Mecatronica";
      case "7":
        return "Ingenieria Materiales";
      default:
        return "Ingenieria en Gestion Empresarial";
    }
  }

  String getInterest(String value) {
    switch (value) {
      case "1":
        return "Hombres";
      case "2":
        return "Mujeres";
      default:
        return "Todxs";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red[900]!, Colors.red[900]!],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPremium) _buildPremiumCard(),
                    const SizedBox(height: 24),
                    _buildAvatarSection(),
                    const SizedBox(height: 24),
                    Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileField(
                      label: 'Nombre',
                      value: name,
                      icon: Icons.person_outline,
                      onTap: () => _showEditDialog(
                        label: 'nombre',
                        initialValue: name,
                        onSave: (value) async {
                          await _updateUserName(value);
                          setState(() => name = value);
                        },
                      ),
                      isPremium: isPremium,
                      isEditable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileField(
                      label: 'Edad',
                      value: age,
                      icon: Icons.cake_outlined,
                      onTap: () => _showEditDialog(
                        label: 'edad',
                        initialValue: age,
                        onSave: (value) => setState(() => age = value),
                      ),
                      isPremium: false,
                      isEditable: false,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileField(
                      label: 'Descripción',
                      value: description,
                      icon: Icons.description_outlined,
                      onTap: () => _showEditDialog(
                        label: 'descripción',
                        initialValue: description,
                        onSave: (value) async {
                          await _updateUserDescription(value);
                          setState(() => description = value);
                        },
                      ),
                      isPremium: isPremium,
                      isEditable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileField(
                      label: 'Instagram',
                      value: instagram,
                      icon: Icons.webhook,
                      onTap: () => _showEditDialog(
                        label: 'Instagram',
                        initialValue: instagram,
                        onSave: (value) async {
                          await _updateUserInstagram(value);
                          setState(() => instagram = value);
                        },
                      ),
                      isPremium: isPremium,
                      isEditable: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preferencias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Género',
                      valueText: getGender(selectedGender),
                      value: selectedGender,
                      icon: Icons.wc_outlined,
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Carrera',
                      valueText: getDegree(selectedCarrera),
                      value: selectedCarrera,
                      icon: Icons.school_outlined,
                      onChanged: (value) {
                        setState(() => selectedCarrera = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Interesado en',
                      valueText: getInterest(selectedInterest),
                      value: selectedInterest,
                      icon: Icons.favorite_outline,
                      onChanged: (value) {
                        setState(() => selectedInterest = value!);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '© ${DateTime.now().year} Aplicación creada por ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Creadores'),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text('Nombre: Fernando Vazquez'),
                                            SizedBox(height: 8),
                                            Text(
                                              'Email: fervazquez@neurovix.com.mx',
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Posicion: Programador',
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cerrar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Neurovix',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[600]!, Colors.red[800]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'TINDERTEC PREMIUM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sube de nivel con cada acción que realices',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/premium_details');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange[700],
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Aprender más',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      height: 420,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              userProfileUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 120, color: Colors.white),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPremium,
    required bool isEditable,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPremium && isEditable ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: !isPremium,
                  child: const Icon(Icons.lock, color: Colors.grey, size: 22),
                ),

                Visibility(
                  visible: isPremium && isEditable,
                  child: const Icon(Icons.edit, color: Colors.red, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required String valueText,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(valueText, style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de la aplicación',
            color: Colors.red[900]!,
            onTap: () async {
              await AuthService().signOut();
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildActionTile(
            icon: Icons.delete_forever,
            title: 'Eliminar cuenta',
            subtitle: 'Sin cuenta atrás',
            color: Colors.red[900]!,
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
