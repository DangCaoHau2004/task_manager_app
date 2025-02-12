import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class Comment extends ConsumerStatefulWidget {
  const Comment({
    super.key,
    required this.uidAdmin,
    required this.idTable,
    required this.idTask,
  });
  final String uidAdmin;
  final String idTask;
  final String idTable;
  @override
  ConsumerState<Comment> createState() => _CommentState();
}

class _CommentState extends ConsumerState<Comment> {
  bool _isLoading = false;
  final _keyCommentForm = GlobalKey<FormState>();
  String _enterComment = "";
  void _addComment() async {
    setState(() {
      _isLoading = true;
    });

    // nếu như có tồn tại idTable thì là comment của  table
    if (_keyCommentForm.currentState!.validate()) {
      _keyCommentForm.currentState!.save();
      if (widget.idTable.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
            .collection("tasks")
            .doc(widget.idTask)
            .collection("tables")
            .doc(widget.idTable)
            .collection("comments")
            .add({
          "content": _enterComment,
          "uid_add": ref.read(userData)["uid"],
          "username": ref.read(userData)["username"],
          "email": ref.read(userData)["email"],
          "uid": ref.read(userData)["uid"],
          "create_at": DateTime.now(),
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("comments")
          .add({
        "content": _enterComment,
        "uid_add": ref.read(userData)["uid"],
        "username": ref.read(userData)["username"],
        "email": ref.read(userData)["email"],
        "uid": ref.read(userData)["uid"],
        "create_at": DateTime.now(),
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // nếu như có tồn tại idTable thì là comment của table
    final Stream<QuerySnapshot> stream = widget.idTable.isNotEmpty
        ? FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
            .collection("tasks")
            .doc(widget.idTask)
            .collection("tables")
            .doc(widget.idTable)
            .collection("comments")
            .orderBy("create_at", descending: true)
            .snapshots()
        : FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
            .collection("tasks")
            .doc(widget.idTask)
            .collection("comments")
            .orderBy("create_at", descending: true)
            .snapshots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comment",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 24,
        ),
        StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No comment",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              final commentData = snapshot.data!.docs;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  children: [
                    ...commentData.map((comment) {
                      final dataComment =
                          comment.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                ),
                                onPressed: () {
                                  final ortherUserData = {
                                    "username": dataComment["username"],
                                    "email": dataComment["email"],
                                    "id": dataComment["uid"],
                                  };
                                  navigatorToOrtherUser(
                                    context,
                                    ortherUserData,
                                    ref.read(userData)["uid"],
                                  );
                                },
                                icon: CircleAvatar(
                                  radius: 15,
                                  backgroundImage: const AssetImage(
                                      "assets/images/user.png"),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onTertiary,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                dataComment["username"] + ":",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                dataComment["content"],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      );
                    })
                  ],
                ),
              );
            }),
        const SizedBox(
          height: 48,
        ),
        Form(
          key: _keyCommentForm,
          child: TextFormField(
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintText: "Comment...",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              suffixIcon: IconButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: _addComment,
                icon: const Icon(
                  Icons.send,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Bạn chưa nhập!";
              }
              return null;
            },
            onSaved: (value) {
              _enterComment = value.toString();
            },
          ),
        ),
        const SizedBox(
          height: 80,
        ),
      ],
    );
  }
}
