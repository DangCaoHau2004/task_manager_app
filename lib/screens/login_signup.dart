import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

final _firebase = FirebaseAuth.instance;

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginSignupScreenState();
  }
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  bool _hidePassword = true;
  bool _hideRePassword = true;
  String _enterEmail = "";
  String _enterPassword = "";
  String _reEnterPassword = "";
  String _enterUsername = "";

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    setState(() {
      _isLoading = true;
    });
    // hủy focus vào input
    FocusScope.of(context).unfocus();

    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState!.save();
    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enterEmail,
          password: _enterPassword,
        );
      } else {
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enterEmail,
          password: _enterPassword,
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
          {
            "username": _enterUsername,
            "email": _enterEmail,
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication failed."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onPrimaryFixed,
              Theme.of(context).colorScheme.primary
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.onTertiary,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 14, right: 14, top: 8, bottom: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //sửa lại font đoạn này!
                      // tiêu đề của form
                      _isLogin
                          ? const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                      // Các ô input của form
                      if (!_isLogin)
                        TextFormField(
                          maxLength: 30,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your username.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enterUsername = value!.trim();
                          },
                        ),

                      // ô nhập email
                      TextFormField(
                        maxLength: 50,
                        decoration: InputDecoration(
                          border: _isLogin
                              ? InputBorder.none
                              : const UnderlineInputBorder(
                                  borderSide: BorderSide(width: 2),
                                ),
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Please enter a valid email!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterEmail = value!.trim();
                        },
                      ),
                      // ô nhập password

                      TextFormField(
                        maxLength: 20,
                        decoration: InputDecoration(
                          border: _isLogin
                              ? InputBorder.none
                              : const UnderlineInputBorder(
                                  borderSide: BorderSide(width: 2),
                                ),
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: _hidePassword
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                        ),
                        obscureText: _hidePassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your password.";
                          }
                          _enterPassword = value;
                          return null;
                        },
                        onSaved: (value) {
                          _enterPassword = value!.trim();
                        },
                        onChanged: (value) {
                          setState(() {
                            _enterPassword = value;
                          });
                        },
                      ),

                      if (!_isLogin)
                        TextFormField(
                          maxLength: 20,
                          decoration: InputDecoration(
                            labelText: "Re-Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideRePassword = !_hideRePassword;
                                });
                              },
                              icon: _hideRePassword
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(
                                      Icons.visibility,
                                    ),
                            ),
                          ),
                          obscureText: _hideRePassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your password.";
                            }
                            if (value != _enterPassword) {
                              return "Password does not match.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _reEnterPassword = value!;
                          },
                        ),

                      if (_isLoading)
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (_isLogin && !_isLoading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                navigatorToForgotPassword(context);
                              },
                              child: const Text(
                                "Forgot pasword?",
                              ),
                            ),
                          ],
                        ),
                      if (!_isLoading)
                        ElevatedButton(
                          onPressed: _submit,
                          child: _isLogin
                              ? const Text("Login")
                              : const Text("Sign-up"),
                        ),

                      // nếu đang ko load thì mới hiện
                      if (!_isLoading)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState!.reset();
                              _hidePassword = true;
                              _hideRePassword = true;
                              FocusScope.of(context).unfocus();
                            });
                          },
                          child: _isLogin
                              ? const Text("You don't have an account?")
                              : const Text("You have an account?"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
