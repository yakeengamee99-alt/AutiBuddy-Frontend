import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screens.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F4EC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No logged-in user found',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong while loading dashboard data\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final Map<String, dynamic> data =
                snapshot.data?.data() as Map<String, dynamic>? ?? {};

            final String parentName = data['name'] ?? 'Parent';

            final int correctNumberAnswers =
                (data['correctNumberAnswers'] ?? 0) as int;

            final int correctAnimalAnswers =
                (data['correctAnimalAnswers'] ?? 0) as int;

            final int correctFoodAnswers =
                (data['correctFoodAnswers'] ?? 0) as int;

            final int pronunciationAccuracy =
                (data['currentPronunciationAccuracy'] ?? 0) as int;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  const Text(
                    "Parent Dashboard",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Welcome, $parentName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCard(
                        title: "Correct number\nanswers",
                        image: "assets/images/11.jpg",
                        value: correctNumberAnswers.toString(),
                      ),
                      const SizedBox(width: 15),
                      buildCard(
                        title: "Correct animal\nanswers",
                        image: "assets/images/22.jpg",
                        value: correctAnimalAnswers.toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCard(
                        title: "Correct vegetables\nand fruits answers",
                        image: "assets/images/33.jpg",
                        value: correctFoodAnswers.toString(),
                      ),
                      const SizedBox(width: 15),
                      buildCard(
                        title: "Pronunciation\naccuracy",
                        image: "assets/images/44.jpg",
                        value: "$pronunciationAccuracy%",
                        isPercentage: true,
                      ),
                    ],
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 40,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BB6B7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreens(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String image,
    required String value,
    bool isPercentage = false,
  }) {
    return Container(
      height: 130,
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Image.asset(image, height: 40),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPercentage ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
