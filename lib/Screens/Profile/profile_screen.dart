import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.whiteTheme),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Account Details",
          style: TextStyle(color: AppColors.whiteTheme),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.orangeShade,
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Muhammad Adnan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  children: const [
                    _DetailItem(title: "Father Name", value: "Muhammad Qasim", icon: Icons.person_2),
                    _DetailItem(title: "Mobile", value: "03260483582", icon: Icons.phone),
                    _DetailItem(title: "Mail", value: "adnanqasim804@gmail.com", icon: Icons.email),
                    _DetailItem(title: "Username", value: "adnan804", icon: Icons.person_outline),
                    _DetailItem(title: "CNIC", value: "12345678909876", icon: Icons.credit_card),
                    _DetailItem(title: "Address", value: "Shujabad Multan", icon: Icons.home),
                    _DetailItem(title: "Gender", value: "Male", icon: Icons.male),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.orangeShade),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
