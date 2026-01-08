import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/models/register_data.dart';
import 'package:tindertec/services/auth_service.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  // -------------------- MAPPERS --------------------

  int getHabitId(String habit) {
    const habits = {
      'Siempre escuchando música': 1,
      'Gym': 2,
      'Amigable': 3,
      'Cafe lover': 4,
      'Extrovertido': 5,
      'Procrastinador': 6,
      'Organizado': 7,
      'Team nocturno': 8,
      'Introvertido': 9,
      'Fan del descanso': 10,
      'Team madrugador': 11,
      'Foráneo': 12,
      'Todo el día en el tec': 13,
      'Me quedo a actividades': 14,
      'Ingeniero': 15,
      'Busco ride': 16,
      'Recursando': 17,
      'Sin dinero': 18,
      'Entro a todas las clases': 19,
    };
    return habits[habit] ?? -1;
  }

  int getGender(String gender) =>
      {'Hombre': 1, 'Mujer': 2, 'Prefiero no decirlo': 3}[gender] ?? -1;

  Future<int> fetchDegreeId(String name) async {
    final res = await Supabase.instance.client
        .from('degrees')
        .select('id_degree')
        .eq('name', name)
        .maybeSingle();

    if (res == null) {
      throw Exception('Degree no encontrado: $name');
    }

    return res['id_degree'] as int;
  }

  Future<int> fetchLookingFor(String name) async {
    final res = await Supabase.instance.client
        .from('looking_for')
        .select('id_looking_for')
        .eq('name', name)
        .maybeSingle();

    if (res == null) {
      throw Exception('Looking_for no encontrado: $name');
    }

    return res['id_looking_for'] as int;
  }

  int getInterest(String value) =>
      {'Hombres': 1, 'Mujeres': 2, 'Todxs': 3}[value] ?? -1;

  // -------------------- PHOTO UPLOAD --------------------

  Future<String> uploadUserPhoto({
    required String userId,
    required File file,
    required int index,
  }) async {
    final supabase = Supabase.instance.client;
    final ext = file.path.split('.').last;
    final path = '$userId/photo_$index.$ext';

    await supabase.storage.from('images').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return supabase.storage.from('images').getPublicUrl(path);
  }

  Future<void> handleSupabaseRegister(RegisterData data) async {
    bool success = false;

    try {
      final password = passwordController.text.trim();
      debugPrint('🟡 Iniciando registro');

      // ---------- AUTH ----------
      final authResponse =
      await authService.signUpWithEmailAndPassword(data.email!, password);

      final user = authResponse.user;
      if (user == null) {
        throw Exception('❌ No se pudo crear el usuario en auth');
      }

      final userId = user.id;
      debugPrint('✅ Usuario auth creado: $userId');

      // ---------- INSERT USERS ----------
      debugPrint('🟡 Insertando en public.users');

      final userInsert = await Supabase.instance.client
          .from('users')
          .insert({
        'id_user': userId,
        'name': data.name,
        'age': data.age,
        'description': data.description,
        'instagram_user': data.instagramUser,
        'profile_completed': true,
        'id_gender': getGender(data.gender!),
        'id_degree': await fetchDegreeId(data.degree!),
        'id_looking_for': await fetchLookingFor(data.lookingFor!),
        'id_interest': getInterest(data.interest!),
      });

      debugPrint('✅ Usuario insertado: $userInsert');

      // ---------- HABITS ----------
      debugPrint('🟡 Insertando hábitos');

      final habits = data.habits ?? [];
      final habitsInsert = habits
          .map((h) {
        final id = getHabitId(h);
        if (id == -1) return null;
        return {'id_user': userId, 'id_life_habit': id};
      })
          .whereType<Map<String, dynamic>>()
          .toList();

      if (habitsInsert.isNotEmpty) {
        await Supabase.instance.client
            .from('user_has_life_habits')
            .insert(habitsInsert);

        debugPrint('✅ Hábitos insertados');
      }

      // ---------- PHOTOS ----------
      debugPrint('🟡 Subiendo fotos');

      final photos = data.photos ?? [];
      if (photos.isEmpty) {
        throw Exception('❌ Debes subir al menos una foto');
      }

      for (int i = 0; i < photos.length; i++) {
        final url = await uploadUserPhoto(
          userId: userId,
          file: photos[i],
          index: i,
        );

        await Supabase.instance.client.from('user_photos').insert({
          'id_user': userId,
          'url': url,
          'order_index': i,
          'is_main': i == 0,
        });

        debugPrint('✅ Foto $i subida: $url');
      }

      success = true;
      debugPrint('🎉 Registro COMPLETADO');

    } on PostgrestException catch (e) {
      debugPrint('❌ POSTGREST ERROR');
      debugPrint('message: ${e.message}');
      debugPrint('details: ${e.details}');
      debugPrint('hint: ${e.hint}');
      debugPrint('code: ${e.code}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DB Error: ${e.message}')),
        );
      }

    } catch (e, s) {
      debugPrint('❌ ERROR GENERAL');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (success && mounted) {
        Navigator.pushNamed(context, '/become_premium');
      }
    }
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final RegisterData data =
    ModalRoute.of(context)!.settings.arguments as RegisterData;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Creando cuenta...'),
          ],
        )
            : ElevatedButton(
          onPressed: passwordController.text.trim().isEmpty
              ? null
              : () {
            setState(() => _isLoading = true);
            handleSupabaseRegister(data);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
          child: const Text(
            'Crear cuenta',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/back_arrow.png',
                  height: 40,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: const Text(
                  'Ahora tu contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: 'Ingresa tu contraseña'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
