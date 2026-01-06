import 'package:flutter/material.dart';
import 'package:tindertec/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String selectedGender = "Hombre";
  String selectedCarrera = '1';
  String selectedInterest = '2';
  String name = 'Fernando Vazquez';
  String age = '21 años';
  String description = 'lorem ipsum';
  String instagram = 'fernandovazquez.fv';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  colors: [
                    Colors.pink[400]!,
                    Colors.pink[300]!,
                    Colors.pink[400]!,
                  ],
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
                    _buildPremiumCard(),
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
                        onSave: (value) => setState(() => name = value),
                      ),
                      isPremium: true,
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
                        onSave: (value) => setState(() => description = value),
                      ),
                      isPremium: true,
                      isEditable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildProfileField(
                      label: 'Instagram',
                      value: instagram,
                      icon: Icons.webhook,
                      onTap: () => _showEditDialog(
                        label: 'número de teléfono',
                        initialValue: instagram,
                        onSave: (value) => setState(() => instagram = value),
                      ),
                      isPremium: false,
                      isEditable: false,
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
                      value: selectedGender,
                      icon: Icons.wc_outlined,
                      items: const [
                        DropdownMenuItem(
                          value: 'Hombre',
                          child: Text('Hombre'),
                        ),
                        DropdownMenuItem(value: 'Mujer', child: Text('Mujer')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Carrera',
                      value: selectedCarrera,
                      icon: Icons.school_outlined,
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text(
                            'Ing. en Sistemas Computacionales',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text(
                            'Ingeniería Eléctrica',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '3',
                          child: Text(
                            'Ingeniería Electrónica',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '4',
                          child: Text(
                            'Ingeniería Industrial',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '5',
                          child: Text(
                            'Ingeniería Mecánica',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '6',
                          child: Text(
                            'Ingeniería Mecatrónica',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '7',
                          child: Text(
                            'Ingeniería en Materiales',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '8',
                          child: Text(
                            'Ing. en Gestión Empresarial',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => selectedCarrera = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Interesado en',
                      value: selectedInterest,
                      icon: Icons.favorite_outline,
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('Hombres')),
                        DropdownMenuItem(value: '2', child: Text('Mujeres')),
                        DropdownMenuItem(value: '3', child: Text('Todxs')),
                      ],
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
                          Text(
                            '© ${DateTime.now().year} Aplicación creada por Neurovix',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
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

  Widget _buildPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red, Colors.pinkAccent],
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
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.pink[600]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt, size: 18, color: Colors.pink[600]),
            ),
          ),
        ],
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
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.pinkAccent, size: 22),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.pinkAccent,
                    size: 22,
                  ),
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
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
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
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.pinkAccent, size: 22),
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
                DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  items: items,
                  onChanged: onChanged,
                ),
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
            color: Colors.red,
            onTap: () async {
              await AuthService().signOut();
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildActionTile(
            icon: Icons.delete_forever,
            title: 'Eliminar cuenta',
            subtitle: 'Sin cuenta atrás',
            color: Colors.red,
            onTap: () async {},
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
