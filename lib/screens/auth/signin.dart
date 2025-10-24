import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? selectedCarrera;
  File? _imageFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  void handleSignIn() {
    final name = nameController.text.trim();
    final lastname = lastnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final edad = edadController.text.trim();
    final altura = alturaController.text.trim();

    if (name.isEmpty ||
        lastname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        edad.isEmpty ||
        altura.isEmpty) {
      _showError('Favor de llenar todos los campos');
      return;
    }

    if (_imageFile == null) {
      _showError('Favor de seleccionar una foto de perfil');
      return;
    }

    if (selectedCarrera == null || selectedCarrera!.isEmpty) {
      _showError('Favor de seleccionar una especialidad');
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, color: Colors.white70, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Foto de perfil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Nombre', nameController, TextInputType.name),
              const SizedBox(height: 15),
              _buildTextField('Apellidos', lastnameController, TextInputType.text),
              const SizedBox(height: 15),
              _buildTextField('Correo electrónico', emailController, TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField('Password', passwordController, TextInputType.text, obscureText: true),
              const SizedBox(height: 15),
              _buildTextField('Edad', edadController, TextInputType.number),
              const SizedBox(height: 15),
              _buildTextField('Altura (m)', alturaController, TextInputType.number),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCarrera,
                dropdownColor: Colors.pinkAccent,
                decoration: _inputDecoration('Especialidad'),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: "Sistemas Computacionales", child: Text("Sistemas Computacionales")),
                  DropdownMenuItem(value: "Industrial", child: Text("Industrial")),
                  DropdownMenuItem(value: "Gestión Empresarial", child: Text("Gestión Empresarial")),
                  DropdownMenuItem(value: "Mecatrónica", child: Text("Mecatrónica")),
                  DropdownMenuItem(value: "Electrónica", child: Text("Electrónica")),
                  DropdownMenuItem(value: "Materiales", child: Text("Materiales")),
                  DropdownMenuItem(value: "Mecánica", child: Text("Mecánica")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCarrera = value;
                  });
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrarme',
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      labelStyle: const TextStyle(color: Colors.white70),
      fillColor: Colors.pinkAccent,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }
}
