import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'animal_page2.dart';

class AnimalPage extends StatelessWidget {
  const AnimalPage({super.key});

  Future<void> updateCorrectAnimalAnswer(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'correctAnimalAnswers': FieldValue.increment(1)},
      );
    } catch (e) {
      print('Update progress error: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update progress: $e')));
    }
  }

  void showWrongAnswer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Try again 😊'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Animals 💙",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Image.asset('assets/images/giraffe.jpg', height: 140),
              ),

              const SizedBox(height: 25),

              buildItem("Giraffe", 'assets/images/giraffe.jpg', context),
              buildItem("Cat", 'assets/images/cat.jpg', context),
              buildItem("Dog", 'assets/images/dog.jpg', context),

              const Spacer(),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(String text, String image, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (text == "Giraffe") {
          await updateCorrectAnimalAnswer(context);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnimalPage2()),
          );
        } else {
          showWrongAnswer(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
