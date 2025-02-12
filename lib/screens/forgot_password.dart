import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _keyForm = GlobalKey<FormState>();
  String _enterEmail = "";
  bool _isLoading = false;
  void _resetPassword() async {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _enterEmail.trim(),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Success, check your email"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
        _isLoading = false;

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
        _isLoading = false;

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot password"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _keyForm,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Enter your email we will send you a password reset link!",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          hintText: "Email ...",
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.trim().contains("@")) {
                            return "Please enter a valid email!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterEmail = value.toString().trim();
                        },
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
