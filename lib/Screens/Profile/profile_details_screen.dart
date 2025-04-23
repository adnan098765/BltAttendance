import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/AppColors/app_colors.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: AppColors.orangeShade,
        title: const Text("Account Details"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.orangeShade,
              child: const Icon(
                Icons.person,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Muhammad Adnan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
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
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
