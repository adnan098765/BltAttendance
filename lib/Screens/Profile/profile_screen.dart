import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../Controllers/get_lpusers_controller.dart';
import '../../Controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final LpUserController lpUserController = Get.put(LpUserController()); // Added LpUserController
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    lpUserController.fetchLpUsers('testUsername'); // Fetch users by username on init
  }

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.user.value == null) {
          return const Center(child: Text("No user data found"));
        }

        final user = controller.user.value!;

        return SingleChildScrollView(
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
              Text(
                user.fullName,
                style: const TextStyle(
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
                    children: [
                      _DetailItem(title: "Father Name", value: user.fatherName, icon: Icons.person_2),
                      _DetailItem(title: "Mobile", value: user.phoneNumber, icon: Icons.phone),
                      _DetailItem(title: "Mail", value: user.email, icon: Icons.email),
                      _DetailItem(title: "Username", value: user.userName, icon: Icons.person_outline),
                      _DetailItem(title: "CNIC", value: user.cnic, icon: Icons.credit_card),
                      _DetailItem(title: "Address", value: user.address, icon: Icons.home),
                      _DetailItem(title: "Gender", value: user.getDisplayGender(), icon: Icons.male),
                      _DetailItem(title: "Joining Date", value: user.registrationDate, icon: Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Displaying list of users fetched from LpUserController
              Obx(() {
                if (lpUserController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (lpUserController.users.isEmpty) {
                  return const Center(child: Text('No LP Users found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: lpUserController.users.length,
                  itemBuilder: (context, index) {
                    final lpUser = lpUserController.users[index];
                    return ListTile(
                      title: Text(lpUser.username),
                      subtitle: Text(lpUser.email),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
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
