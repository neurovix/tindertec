import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File?> _photos = List.generate(6, (_) => null);

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _photos[index] = File(pickedFile.path);
      });
    }
  }

  int get _photoCount => _photos.where((p) => p != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _photoCount == 0
                ? null
                : () {
              Navigator.pushNamed(context, '/password');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _photoCount == 0 ? Colors.grey.shade300 : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Siguiente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 28),
              ),

              const SizedBox(height: 30),

              const Text(
                'Agrega tus fotos',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final photo = _photos[index];

                  return GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(18),
                        image: photo != null
                            ? DecorationImage(
                          image: FileImage(photo),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: photo == null
                          ? const Center(
                        child: Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.black54,
                        ),
                      )
                          : null,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_photoCount/6',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
}
