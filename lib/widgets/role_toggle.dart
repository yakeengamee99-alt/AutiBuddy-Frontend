import 'package:flutter/material.dart';

class RoleToggle extends StatelessWidget {
  final bool isParent;
  final ValueChanged<bool> onChanged;

  const RoleToggle({Key? key, required this.isParent, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Parent tab
          _tabItem(
            title: "Parent",
            selected: isParent,
            onTap: () => onChanged(true),
          ),

          // Buddy tab
          _tabItem(
            title: "Buddy",
            selected: !isParent,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
