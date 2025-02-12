import 'package:flutter/material.dart';

Widget loadingWidget(String message) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const Center(
        child: CircularProgressIndicator(),
      ),
    ],
  );
}

Widget errorWidget(String errorMessage, String message) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
    ],
  );
}

Widget noElementWidget(String message) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const Center(
        child:
            Text("No recent tasks available.", style: TextStyle(fontSize: 16)),
      ),
    ],
  );
}
