import 'package:flutter/material.dart';

class Policy extends StatelessWidget {
  const Policy({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Policy"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const Text("ABCXYZ"),
      ),
    );
  }
}
