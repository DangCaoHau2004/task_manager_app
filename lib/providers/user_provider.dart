import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final data =
      await FirebaseFirestore.instance.collection("users").doc(uid).get();
  if (data.exists) {
    return data.data() as Map<String, dynamic>;
  } else {
    throw Exception("User không tồn tại!");
  }
});
final userData = StateProvider<Map<String, dynamic>>((ref) => {});
