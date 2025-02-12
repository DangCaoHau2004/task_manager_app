import 'package:cloud_firestore/cloud_firestore.dart';

void addNotification({
  required String uidUser,
  required String redirect,
  required String content,
  required String type,
  required String by,
  idTask = null,
  uidAdmin = null,
  uid = null,
}) {
  FirebaseFirestore.instance
      .collection("users")
      .doc(uidUser)
      .collection("notifications")
      .add(
    {
      "create_at": DateTime.now(),
      "redirect": redirect,
      "content": content,
      "by": by,
      "id_task": idTask,
      "uidAdmin": uidAdmin,
      "uid": uid,
    },
  );
}
