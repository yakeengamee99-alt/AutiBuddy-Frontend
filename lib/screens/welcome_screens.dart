import 'package:flutter/material.dart';
import 'login_screens.dart';
import 'register_screens.dart';

class WelcomeScreens extends StatelessWidget {
  const WelcomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E8),
      body: Column(
        children: [
          // Top blue section
          Container(
            height: 320,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4DB6AC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AutiBuddy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Image.asset(
                    'assets/images/onboarding.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          // Login Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB6AC),
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login'); // يروح LoginScreen
            },
            child: const Text('Login', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 25),
          // Register Button
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register'); // يروح RegisterScreen
            },
            child: const Text('Register', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
