import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/add_user.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen(
      {super.key,
      required this.taskData,
      required this.currentUserData,
      required this.allUser,
      required this.uidAdmin});
  final Map<String, dynamic> taskData;
  final Map<String, dynamic> currentUserData;
  final List<QueryDocumentSnapshot> allUser;
  final String uidAdmin;
  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  List<QueryDocumentSnapshot> allUserInTask = [];
  @override
  void initState() {
    setState(() {
      allUserInTask = widget.allUser;
    });
    super.initState();
  }

  bool _isLoading = false;

  final _formSearchKey = GlobalKey<FormState>();
  String _enterSearch = "";
  void _searchElement() async {
    final validate = _formSearchKey.currentState!.validate();
    if (!validate) {
      setState(() {
        _enterSearch = "";
      });
      return;
    }
    _formSearchKey.currentState!.save();
  }

  void _showModalBottomAddUserScreen(
      String username, String uid, String email, String idTask) async {
    final res = await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) {
          return AddUser(
            email: email,
            uid: uid,
            username: username,
            idTask: idTask,
            taskData: widget.taskData,
            uidAdmin: widget.uidAdmin,
          );
        });
    if (res != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            await FirebaseFirestore.instance
                .collection("users")
                .doc(widget.uidAdmin)
                .collection("tasks")
                .doc(idTask)
                .collection("users")
                .doc(uid)
                .delete();

            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("tasks")
                .doc(idTask)
                .delete();
            setState(() {
              _isLoading = false;
            });
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskData["task_name"]),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                if (widget.currentUserData["role"] == null)
                  const Center(
                    child: Text("Access denied."),
                  ),
                if (widget.currentUserData["role"] != null)
                  // Text(
                  //   widget.taskData["id"],
                  // ),
                  // Thanh tìm kiếm
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formSearchKey,
                      child: TextFormField(
                        onChanged: (value) {
                          _searchElement();
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          hintText: "Email...",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              _searchElement();
                            },
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return "Please enter corectly!";
                          }
                          if (value.trim() == ref.read(userData)["email"]) {
                            return "Please do not enter your email.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _enterSearch = value!.trim();
                          });
                        },
                      ),
                    ),
                  ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(ref.read(userData)["uid"])
                      .collection("friends")
                      .where("status", isEqualTo: "friend")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                            "Please add a friend before using this feature."),
                      );
                    }
                    var friendData = [];
                    // nếu như thanh tìm kiếm ko trống
                    if (_enterSearch.isNotEmpty) {
                      for (final data in snapshot.data!.docs) {
                        if (data["email"].toString().contains(_enterSearch)) {
                          friendData.add(data);
                        }
                      }
                    } else {
                      if (snapshot.data != null) {
                        friendData = snapshot.data!.docs;
                      }
                    }

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.uidAdmin)
                          .collection("tasks")
                          .doc(widget.taskData["id"])
                          .collection("users")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                                "Please add a friend before using this feature."),
                          );
                        }
                        List<String> allUserIds =
                            snapshot.data!.docs.map((doc) => doc.id).toList();
                        friendData = friendData.where((friend) {
                          if (!allUserIds.contains(friend.id)) {
                            return true;
                          }
                          return false;
                        }).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              if (friendData.isEmpty)
                                Center(
                                  child: Text(_enterSearch.isEmpty
                                      ? "You need to be friends to add members."
                                      : "No user found with that email."),
                                ),
                              if (friendData.isNotEmpty)
                                ...friendData.map((friend) {
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                alignment: Alignment.centerLeft,
                                              ),
                                              onPressed: () {
                                                final ortherUserData = {
                                                  "username":
                                                      friend.data()["username"],
                                                  "email":
                                                      friend.data()["email"],
                                                  "id": friend.id
                                                };
                                                navigatorToOrtherUser(
                                                    context,
                                                    ortherUserData,
                                                    ref.read(userData)["uid"]);
                                              },
                                              child: Text(
                                                friend.data()["email"],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                alignment: Alignment.center),
                                            onPressed: () {
                                              _showModalBottomAddUserScreen(
                                                  friend.data()["username"],
                                                  friend.id,
                                                  friend.data()["email"],
                                                  widget.taskData["id"]);
                                            },
                                            child: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                  );
                                }),
                            ],
                          ),
                        );
                      },
                    );

                    // lọc bỏ bạn bè những người đã ở trong dự án
                  },
                )
              ],
            ),
    );
  }
}
