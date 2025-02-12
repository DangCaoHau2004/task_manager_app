import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class ChangeRoleUser extends ConsumerStatefulWidget {
  const ChangeRoleUser({
    super.key,
    required this.email,
    required this.uidUser,
    required this.uidAdmin,
    required this.username,
    required this.idTask,
    required this.taskData,
    required this.role,
    required this.userData,
    required this.userCurrentRole,
  });

  final String email;
  final String username;
  final String uidUser;
  final String uidAdmin;
  final String idTask;
  final String role;
  final String userCurrentRole;
  final Map<String, dynamic> taskData;
  final QueryDocumentSnapshot userData;

  @override
  ConsumerState<ChangeRoleUser> createState() => _ChangeRoleUserState();
}

class _ChangeRoleUserState extends ConsumerState<ChangeRoleUser> {
  final _formKey = GlobalKey<FormState>();
  final _roleList = ["Project Manager", "Member"];
  String _selectedRole = "Member";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;
  }

  void _changeRoleUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final role = _selectedRole == "Member" ? "member" : "project_manager";

        await FirebaseFirestore.instance
            .collection("users")
            .doc(ref.read(userData)["uid"])
            .collection("tasks")
            .doc(widget.idTask)
            .collection("users")
            .doc(widget.uidUser)
            .set({
          "email": widget.email,
          "username": widget.username,
          "role": role,
          "create_at": DateTime.now(),
        });

        // Merge task data for the user
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidUser)
            .collection("tasks")
            .doc(widget.idTask)
            .set({
          "create_at": DateTime.now(),
        }, SetOptions(merge: true));

        setState(() {
          _isLoading = false;
        });

        // gửi thông báo cho toàn bộ user trong task
        final allUserInTask = await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
            .collection("tasks")
            .doc(widget.idTask)
            .collection("users")
            .get();
        for (final user in allUserInTask.docs) {
          addNotification(
            uidUser: user.id,
            redirect: "all_table",
            type: "edit_role",
            content: "${widget.username} is change role!",
            by: ref.read(userData)["email"],
            idTask: widget.idTask,
            uidAdmin: widget.uidAdmin,
          );
        }

        Navigator.pop(context, "success");
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, e.toString());
      }
    }
  }

  void _removeUser() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("tasks")
          .doc(widget.idTask)
          .collection("users")
          .doc(widget.uidUser)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidUser)
          .collection("tasks")
          .doc(widget.idTask)
          .delete();

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, "Success");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, {"message": e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: keyboardSpace + 16,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change user role in task",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 24),
              const Text(
                "Name:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text(widget.username),
              const SizedBox(height: 18),
              const Text(
                "Email:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text(widget.email),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: _roleList.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Select Role",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 200),
                    Center(
                      child: ElevatedButton(
                        onPressed: _changeRoleUser,
                        child: const Text("Change Role"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.userCurrentRole == "admin")
                      Center(
                        child: TextButton(
                          onPressed: _removeUser,
                          child: const Text(
                            "Remove User",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
