import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class AddUser extends ConsumerStatefulWidget {
  const AddUser({
    super.key,
    required this.email,
    required this.uid,
    required this.username,
    required this.idTask,
    required this.taskData,
    required this.uidAdmin,
  });
  final String email;
  final String username;
  final String uid;
  final String idTask;
  final String uidAdmin;
  final Map<String, dynamic> taskData;
  @override
  ConsumerState<AddUser> createState() => _AddUserState();
}

class _AddUserState extends ConsumerState<AddUser> {
  final _formkey = GlobalKey<FormState>();
  final _listRole = ["Project Manager", "Member"];
  String _selectedRole = "Member";
  var _isLoading = false;
  void _addUserToTask() async {
    FocusScope.of(context).unfocus();

    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final role = _selectedRole == "Member" ? "member" : "project_manager";
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
            .collection("tasks")
            .doc(widget.idTask)
            .collection("users")
            .doc(widget.uid)
            .set({
          "email": widget.email,
          "username": widget.username,
          "role": role,
          "create_at": DateTime.now(),
        });

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uid)
            .collection("tasks")
            .doc(widget.idTask)
            .set({
          "reference": "${"users/" + widget.uidAdmin}/tasks/${widget.idTask}",
          "create_at": DateTime.now(),
          "start_date": widget.taskData["start_date"],
          "end_date": widget.taskData["end_date"],
          "task_name": widget.taskData["task_name"],
        });
        setState(() {
          _isLoading = false;
        });
// gửi thông báo cho user vừa được add

        addNotification(
          uidUser: widget.uid,
          redirect: "all_table",
          type: "add_user",
          content:
              "You has been added to the task ${widget.taskData["task_name"]}",
          by: ref.read(userData)["email"],
          idTask: widget.idTask,
          uidAdmin: widget.uidAdmin,
        );
        Navigator.pop(context, "Success");
      } catch (e) {
        Navigator.pop(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add user to task",
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
          const SizedBox(
            height: 24,
          ),
          Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown for role selection
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: _listRole.map((role) {
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
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _addUserToTask,
                    child: const Text("Add"),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
