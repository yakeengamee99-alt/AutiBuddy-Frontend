import 'package:flutter/material.dart';
import 'number_page.dart';
import 'animal_page.dart';
import 'fv_page.dart';
import 'voice_page.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Row(
                children: const [
                  Text(
                    "Exercises",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.extension),
                ],
              ),

              const SizedBox(height: 30),

              /// Buttons (زي ما هم بدون تغيير)
              ExerciseItem(title: "Numbers", image: "assets/images/22.jpg"),

              ExerciseItem(title: "Animals", image: "assets/images/33.jpg"),

              ExerciseItem(
                title: "Vegetables & fruits",
                image: "assets/images/11.jpg",
              ),

              ExerciseItem(
                title: "Voice practice",
                image: "assets/images/voice.jpg",
              ),

              const Spacer(),

              /// Back Button
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4BB6B7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 18),
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

class ExerciseItem extends StatelessWidget {
  final String title;
  final String image;

  const ExerciseItem({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          /// ✅ التنقل بين الصفحات
          if (title == "Numbers") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NumbersPage()),
            );
          } else if (title == "Animals") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnimalPage()),
            );
          } else if (title == "Vegetables & fruits") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FVPage()),
            );
          } else if (title == "Voice practice") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LionScreen()),
            );
          }
        },
        child: Row(
          children: [
            CircleAvatar(radius: 35, backgroundImage: AssetImage(image)),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
