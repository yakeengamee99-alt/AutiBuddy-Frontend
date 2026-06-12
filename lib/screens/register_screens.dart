import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/api_service.dart';
import 'home_screens.dart';
import 'welcome_screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController childNameController = TextEditingController();
  final TextEditingController childAgeController = TextEditingController();

  String relationToChild = 'Parent';
  String childGender = 'Male';

  bool isLoading = false;

  Future<void> registerUser() async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String childName = childNameController.text.trim();
    final String childAgeText = childAgeController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        childName.isEmpty ||
        childAgeText.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match');
      return;
    }

    final int? childAge = int.tryParse(childAgeText);

    if (childAge == null || childAge <= 0) {
      showMessage('Please enter a valid child age');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // 1) Register parent and child in Backend API
      final Map<String, dynamic> apiParent = await ApiService.registerParent(
        name: name,
        email: email,
        password: password,
        relationToChild: relationToChild,
        childName: childName,
        childAge: childAge,
        childGender: childGender,
      );

      final int parentId = apiParent['id'] ?? apiParent['Id'];

      // 2) Get childId from Backend API
      final List<dynamic> children = await ApiService.getChildrenByParent(
        parentId,
      );

      int? childId;

      if (children.isNotEmpty) {
        childId = children.first['id'] ?? children.first['Id'];
      }

      // 3) Register user in Firebase Auth
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        // 4) Save Firebase + API data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'Parent or Teacher',
          'relationToChild': relationToChild,
          'childName': childName,
          'childAge': childAge,
          'childGender': childGender,
          'apiParentId': parentId,
          'apiChildId': childId,
          'appName': 'AutiBuddy',
          'correctNumberAnswers': 0,
          'correctAnimalAnswers': 0,
          'correctFoodAnswers': 0,
          'pronunciationAccuracy': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreens(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered in Firebase';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.message != null) {
        message = e.message!;
      }

      showMessage(message);
    } catch (e) {
      showMessage(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    childNameController.dispose();
    childAgeController.dispose();
    super.dispose();
  }

  Widget _textField(
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPassword ? TextInputType.visiblePassword : keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          border: const UnderlineInputBorder(),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 35),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Join AutiBuddy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 35),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _textField(
                            'Parent / Teacher Name',
                            controller: nameController,
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                          ),
                          _textField(
                            'Email',
                            controller: emailController,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _textField(
                            'Password',
                            isPassword: true,
                            controller: passwordController,
                            icon: Icons.lock_outline,
                          ),
                          _textField(
                            'Confirm Password',
                            isPassword: true,
                            controller: confirmPasswordController,
                            icon: Icons.lock_outline,
                          ),

                          const SizedBox(height: 5),

                          _dropdownField(
                            value: relationToChild,
                            items: const [
                              'Parent',
                              'Teacher',
                              'Mother',
                              'Father',
                            ],
                            icon: Icons.family_restroom_outlined,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                relationToChild = value;
                              });
                            },
                          ),

                          _textField(
                            'Child Name',
                            controller: childNameController,
                            icon: Icons.child_care_outlined,
                            keyboardType: TextInputType.name,
                          ),

                          _textField(
                            'Child Age',
                            controller: childAgeController,
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),

                          _dropdownField(
                            value: childGender,
                            items: const [
                              'Male',
                              'Female',
                            ],
                            icon: Icons.wc_outlined,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                childGender = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: isLoading ? null : registerUser,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreens(),
                  ),
                );
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}