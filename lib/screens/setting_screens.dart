import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'change_password_screens.dart';
import 'change_email_screens.dart';
import 'change_name_screens.dart';
import 'welcome_screens.dart';
import 'home_screens.dart';

class SettingsScreens extends StatefulWidget {
  const SettingsScreens({super.key});

  @override
  State<SettingsScreens> createState() => _SettingsScreensState();
}

class _SettingsScreensState extends State<SettingsScreens> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();

    if (!mounted) return;

    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreens()),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        if (!mounted) return;

        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      showMessage('Failed to pick image');
    }
  }

  void _deleteImage() {
    setState(() {
      _imageBytes = null;
    });
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete Photo",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _deleteImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreens()),
      (route) => false,
    );
  }

  Future<void> openChangeNameScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeNameScreen()),
    );

    await refreshUser();
  }

  Future<void> openChangeEmailScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
    );

    await refreshUser();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _settingItem({
    required IconData icon,
    required String text,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Text(text, style: TextStyle(fontSize: 16, color: textColor)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'No email';

    final name =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user!.displayName!
        : 'No name';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: goToHome,
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 30,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : null,
              child: _imageBytes == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _showEditOptions(context),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 20),
                  SizedBox(height: 4),
                  Text('Edit'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(
              email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _settingItem(
              icon: Icons.edit,
              text: 'Change Name',
              onTap: openChangeNameScreen,
            ),

            _settingItem(
              icon: Icons.lock_outline,
              text: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            _settingItem(
              icon: Icons.email_outlined,
              text: 'Change Email',
              onTap: openChangeEmailScreen,
            ),

            _settingItem(
              icon: Icons.power_settings_new,
              text: 'Log Out',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: logoutUser,
            ),
          ],
        ),
      ),
    );
  }
}
