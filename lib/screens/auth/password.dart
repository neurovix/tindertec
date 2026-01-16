import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tindertec/models/register_data.dart';
import 'package:tindertec/services/auth_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final authService = AuthService();
  bool _isLoading = false;

  // -------------------- IMAGE COMPRESSION --------------------

  Future<File> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: 1080,
        minHeight: 1350,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('⚠️ Compresión falló, usando archivo original');
        return file;
      }

      final compressedFile = File(result.path);
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();

      debugPrint(
        '✅ Imagen comprimida: ${(originalSize / 1024).toStringAsFixed(2)} KB → ${(compressedSize / 1024).toStringAsFixed(2)} KB',
      );

      return compressedFile;
    } catch (e) {
      debugPrint('⚠️ Error en compresión: $e, usando archivo original');
      return file;
    }
  }

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

  int getInterest(String value) =>
      {'Hombres': 1, 'Mujeres': 2, 'Todxs': 3}[value] ?? -1;

  Future<int> fetchDegreeId(String name) async {
    final res = await Supabase.instance.client
        .from('degrees')
        .select('id_degree')
        .eq('name', name)
        .maybeSingle();

    if (res == null) throw Exception('Degree no encontrado');
    return res['id_degree'];
  }

  Future<int> fetchLookingFor(String name) async {
    final res = await Supabase.instance.client
        .from('looking_for')
        .select('id_looking_for')
        .eq('name', name)
        .maybeSingle();

    if (res == null) throw Exception('Looking_for no encontrado');
    return res['id_looking_for'];
  }

  // -------------------- PHOTO UPLOAD --------------------

  Future<String> uploadUserPhoto({
    required String userId,
    required File file,
    required int index,
  }) async {
    final supabase = Supabase.instance.client;

    final compressed = await compressImage(file);

    final path = '$userId/photo_$index.jpg';

    await supabase.storage
        .from('images')
        .upload(
          path,
          compressed,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return supabase.storage.from('images').getPublicUrl(path);
  }

  Future<Map<String, dynamic>> resolveDegree(RegisterData data) async {
    if (data.degree == 'Otra') {
      final otraId = await fetchDegreeId('Otra');

      return {
        'id_degree': otraId,
        'custom_degree': data.customDegree,
      };
    }

    return {
      'id_degree': await fetchDegreeId(data.degree!),
      'custom_degree': null,
    };
  }

  // -------------------- REGISTER FLOW --------------------

  Future<void> handleSupabaseRegister(RegisterData data) async {
    bool success = false;

    try {
      final password = passwordController.text.trim();

      final authResponse = await authService.signUpWithEmailAndPassword(
        data.email!,
        password,
      );

      final user = authResponse.user;
      if (user == null) throw Exception('No se pudo crear usuario');

      final userId = user.id;

      final degreeData = await resolveDegree(data);

      debugPrint('DEGREE: ${data.degree}');
      debugPrint('CUSTOM DEGREE: ${data.customDegree}');

      await Supabase.instance.client.from('users').insert({
        'id_user': userId,
        'name': data.name,
        'age': data.age,
        'description': data.description,
        'instagram_user': data.instagramUser,
        'profile_completed': true,
        'id_gender': getGender(data.gender!),
        'id_degree': degreeData['id_degree'],
        'custom_degree': degreeData['custom_degree'],
        'id_looking_for': await fetchLookingFor(data.lookingFor!),
        'id_interest': getInterest(data.interest!),
      });

      final habits = data.habits ?? [];
      if (habits.isNotEmpty) {
        await Supabase.instance.client
            .from('user_has_life_habits')
            .insert(
              habits
                  .map(
                    (h) => {'id_user': userId, 'id_life_habit': getHabitId(h)},
                  )
                  .where((e) => e['id_life_habit'] != -1)
                  .toList(),
            );
      }

      final photos = data.photos ?? [];
      if (photos.isEmpty) throw Exception('Debes subir al menos una foto');

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
      }

      success = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
        debugPrint("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/become_premium',
          (route) => false,
        );
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
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
                child: Image.asset('assets/icons/back_arrow.png', height: 40),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Ahora tu contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ingresa tu contraseña',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
