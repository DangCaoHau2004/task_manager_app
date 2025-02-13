import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends ConsumerState<EditProfile> {
  String _enterUsername = "";
  bool _isLoading = false;
  void _editProfile() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        FirebaseFirestore.instance
            .collection("users")
            .doc(ref.read(userData)["uid"])
            .update(
          {
            "username": _enterUsername,
          },
        );
        ref.read(userData.notifier).state = {
          "username": _enterUsername,
          "email": ref.read(userData)["email"],
          "uid": ref.read(userData)["uid"],
        };

        Navigator.pop(context, "Success");
      } catch (e) {
        Navigator.pop(context, e.toString());
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
            children: [
              const Text(
                "Edit profile",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Name:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Name ...",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterUsername = value.toString();
                      },
                      initialValue: ref.read(userData)["username"],
                    ),

                    const SizedBox(
                      height: 200,
                    ),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _editProfile,
                        child: const Text("Edit"),
                      ),
                    ),
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
