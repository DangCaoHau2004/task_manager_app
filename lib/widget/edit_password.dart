import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPassword extends ConsumerStatefulWidget {
  const EditPassword({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EditPasswordState();
  }
}

class _EditPasswordState extends ConsumerState<EditPassword> {
  String _enterOldPassword = "";
  String _enterNewPassword = "";
  String _reEnterNewPassword = "";
  bool _isLoading = false;
  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  void _EditPassword() async {
    setState(() {
      _isLoading = true;
    });
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        final user = FirebaseAuth.instance.currentUser;
        final cred = EmailAuthProvider.credential(
            email: ref.read(userData)["email"], password: _enterOldPassword);
        await user!.reauthenticateWithCredential(cred).then(
          (value) async {
            await user.updatePassword(_reEnterNewPassword);
          },
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Success"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ));
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).popUntil((route) => route.isFirst);
        await FirebaseAuth.instance.signOut();
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
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
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
                "Edit password",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Old password:",
                      style: TextStyle(fontSize: 18),
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
                        hintText: "Old password ...",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideOldPassword = !_hideOldPassword;
                            });
                          },
                          icon: _hideOldPassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      obscureText: _hideOldPassword,
                      onSaved: (value) {
                        setState(() {
                          _enterOldPassword = value.toString();
                        });
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      "New password:",
                      style: TextStyle(fontSize: 18),
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
                        hintText: "New password ...",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideNewPassword = !_hideNewPassword;
                            });
                          },
                          icon: _hideNewPassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _enterNewPassword = value;
                        });
                      },
                      obscureText: _hideNewPassword,
                      onSaved: (value) {
                        _enterNewPassword = value.toString();
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      "Confirm new password:",
                      style: TextStyle(fontSize: 18),
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
                        hintText: "Cornfirm new password ...",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideNewPassword = !_hideNewPassword;
                            });
                          },
                          icon: _hideNewPassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        print(value);
                        print(_enterNewPassword);
                        if (value.trim() != _enterNewPassword) {
                          return "New password and confirmation do not match.";
                        }
                        return null;
                      },
                      obscureText: _hideNewPassword,
                      onSaved: (value) {
                        setState(() {
                          _reEnterNewPassword = value.toString();
                        });
                      },
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _EditPassword,
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
