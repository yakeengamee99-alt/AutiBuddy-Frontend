import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    newEmailController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> updateEmail() async {
    final String newEmail = newEmailController.text.trim();
    final String currentPassword = currentPasswordController.text.trim();

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      showMessage('Enter a valid new email');
      return;
    }

    if (currentPassword.isEmpty) {
      showMessage('Enter your current password');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      showMessage('User not logged in');
      return;
    }

    try {
      setState(() => isLoading = true);

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);

      if (!mounted) return;

      showMessage(
        'Verification email sent. Please check the new email inbox and spam.',
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to change email';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already in use';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please log out and log in again, then try changing email.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please try again later.';
      } else if (e.message != null) {
        message = e.message!;
      }

      if (!mounted) return;
      showMessage(message);
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? 'No email';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text(
          'Change Email',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Current email: $currentEmail',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                labelText: 'New Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: currentPasswordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Current Password',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

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
                onPressed: isLoading ? null : updateEmail,
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
                        'Send Verification Email',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
