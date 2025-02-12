import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/change_role_user.dart';

class AllUserScreen extends ConsumerStatefulWidget {
  const AllUserScreen({
    super.key,
    required this.taskData,
    required this.currentUserData,
    required this.uidAdmin,
  });
  final Map<String, dynamic> taskData;
  final Map<String, dynamic> currentUserData;
  final String uidAdmin;

  @override
  ConsumerState<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends ConsumerState<AllUserScreen> {
  Stream<QuerySnapshot> _getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uidAdmin)
        .collection('tasks')
        .doc(widget.taskData['id'])
        .collection('users')
        .orderBy("create_at")
        .snapshots();
  }

  void _showModalBottomChangeUserScreen(
      String username,
      String uidUser,
      String uidAdmin,
      String email,
      String idTask,
      String role,
      String userCurrentRole,
      QueryDocumentSnapshot userData) async {
    final res = await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) {
          return ChangeRoleUser(
            email: email,
            uidUser: uidUser,
            uidAdmin: uidAdmin,
            username: username,
            idTask: idTask,
            taskData: widget.taskData,
            role: role,
            userData: userData,
            userCurrentRole: userCurrentRole,
          );
        });

    if (res != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(uidAdmin)
                  .collection("tasks")
                  .doc(idTask)
                  .collection("users")
                  .doc(uidUser)
                  .set({
                "email": email,
                "username": username,
                "role": role,
                "create_at": DateTime.now(),
              });

              FirebaseFirestore.instance
                  .collection("users")
                  .doc(uidUser)
                  .collection("tasks")
                  .doc(idTask)
                  .set(
                {
                  "reference": "${"users/" + uidAdmin}/tasks/${idTask}",
                  "create_at": DateTime.now(),
                  "start_date": widget.taskData["start_date"],
                  "end_date": widget.taskData["end_date"],
                },
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = ref.read(userData)["uid"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("All user"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              "All user of task: ${widget.taskData["task_name"]}",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 24,
            ),
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Role",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allUserInTask = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: allUserInTask.length,
                    itemBuilder: (context, idx) {
                      final userData =
                          allUserInTask[idx].data() as Map<String, dynamic>? ??
                              {};

                      final role = userData["role"] == "member"
                          ? "Member"
                          : userData["role"] == "admin"
                              ? "Admin"
                              : "Project Manager";

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(0),
                                    ),
                                    onPressed: () {
                                      navigatorToOrtherUser(
                                        context,
                                        {
                                          "username": userData["username"],
                                          "email": userData["email"],
                                          "id": allUserInTask[idx].id,
                                        },
                                        currentUserUid,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            userData["email"] ?? "Loading",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            role,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        if (role == "Admin" ||
                                            widget.currentUserData["role"] ==
                                                "member")
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.currentUserData["role"] != null &&
                                    widget.currentUserData["role"] !=
                                        "member" &&
                                    role != "Admin")
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () {
                                        _showModalBottomChangeUserScreen(
                                          userData["username"],
                                          allUserInTask[idx].id,
                                          widget.uidAdmin,
                                          userData["email"],
                                          widget.taskData["id"],
                                          role,
                                          widget.currentUserData["role"],
                                          allUserInTask[idx],
                                        );
                                      },
                                      icon: const Icon(Icons.edit_document),
                                    ),
                                  ),
                              ],
                            ),
                            Container(
                              height: 0.2,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
