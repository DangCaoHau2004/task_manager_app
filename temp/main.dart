import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigator(
      {required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(2, (index) {
              return GestureDetector(
                onTap: () => onTap(index == 1 ? 2 : index),
                child: Icon(
                  [Icons.home, Icons.person][index],
                  color: currentIndex == (index == 1 ? 2 : index)
                      ? Colors.blue
                      : Colors.black54,
                  size: 30,
                ),
              );
            }),
          ),
        ),
        FloatingActionButton(
          onPressed: () => onTap(1),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, size: 30),
        ),
      ],
    );
  }
}
