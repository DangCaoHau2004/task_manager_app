import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class ProfileOrtherUser extends ConsumerStatefulWidget {
  const ProfileOrtherUser({super.key, required this.ortherUserData});

  final Map<String, dynamic> ortherUserData;
  @override
  ConsumerState<ProfileOrtherUser> createState() => _ProfileOrtherUserState();
}

class _ProfileOrtherUserState extends ConsumerState<ProfileOrtherUser> {
  var _isLoading = false;
  void _addFriend(uid, email, username) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("friends")
          .doc(uid)
          .set({
        "email": email,
        "username": username,
        "status": "add",
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(ref.read(userData)["uid"])
          .set({
        "email": ref.read(userData)["email"],
        "username": ref.read(userData)["username"],
        "status": "request",
      });
      setState(() {
        _isLoading = false;
      });
      final curUsername = ref.read(userData)["username"];
      addNotification(
        uidUser: uid,
        redirect: "list_friend",
        content: "You have a new friend request from $curUsername!",
        type: "add_friend",
        by: ref.read(userData)["email"],
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  void _cancleFriendRequest(uid) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // xóa bỏ dữ liệu đoạn chat ra khỏi db
      final result = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("chats")
          .doc(ref.read(userData)["uid"])
          .get();
      if (result.data() != null) {
        final idChat = result.data()!["id"];
        if (idChat != null && idChat.toString().isNotEmpty) {
          FirebaseFirestore.instance.collection("chats").doc(idChat).delete();
        }
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("friends")
          .doc(uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("chats")
          .doc(uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(ref.read(userData)["uid"])
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("chats")
          .doc(ref.read(userData)["uid"])
          .delete();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  void _acceptFriendRequest(uid) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("friends")
          .doc(uid)
          .set(
        {"status": "friend"},
        SetOptions(
          merge: true,
        ),
      );
      final idChat = await FirebaseFirestore.instance.collection("chats").add({
        "last_message": null,
        "is_read": null,
        "create_at": DateTime.now(),
        "uid": null,
      });
      // thêm thông tin user vào đoạn chat
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("chats")
          .doc(uid)
          .set(
        {
          "username": widget.ortherUserData["username"],
          "create_at": DateTime.now(),
          "id": idChat.id,
          "email": widget.ortherUserData["email"],
        },
        SetOptions(
          merge: true,
        ),
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(ref.read(userData)["uid"])
          .set(
        {"status": "friend"},
        SetOptions(
          merge: true,
        ),
      );

      // thêm thông tin user vào đoạn chat
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("chats")
          .doc(ref.read(userData)["uid"])
          .set(
        {
          "username": ref.read(userData)["username"],
          "create_at": DateTime.now(),
          "id": idChat.id,
          "email": widget.ortherUserData["email"],
        },
        SetOptions(
          merge: true,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ortherUserData["username"]),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 80),
        color: Theme.of(context).colorScheme.onTertiary,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: const AssetImage("assets/images/user.png"),
              backgroundColor: Theme.of(context).colorScheme.onTertiary,
            ),
            const SizedBox(height: 20),
            Text(
              widget.ortherUserData["username"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(widget.ortherUserData["email"]),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(ref.read(userData)["uid"])
                      .collection("friends")
                      .doc(widget.ortherUserData["id"])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Err: ${snapshot.error}"),
                      );
                    } else if (snapshot.hasData &&
                        snapshot.data!.data() != null &&
                        snapshot.data!.data()!.isNotEmpty) {
                      final status = snapshot.data!.data()!["status"];
                      // đã gửi lời mời!
                      if (status == "add") {
                        return OutlinedButton(
                          onPressed: () {
                            _cancleFriendRequest(widget.ortherUserData["id"]);
                          },
                          child: Center(
                            child: Text(
                              "Cancel friend request",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      } else if (status == "request") {
                        return Column(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                _acceptFriendRequest(
                                    widget.ortherUserData["id"]);
                              },
                              child: Center(
                                child: Text(
                                  "Accept friend request",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                _cancleFriendRequest(
                                    widget.ortherUserData["id"]);
                              },
                              child: Center(
                                child: Text(
                                  "Cancel friend request",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      // đã là bạn bè
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "Friend",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              navigatorToChat(
                                  context, widget.ortherUserData["id"]);
                            },
                            child: Center(
                              child: Text(
                                "Chat",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                ),
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              _cancleFriendRequest(widget.ortherUserData["id"]);
                            },
                            child: Center(
                              child: Text(
                                "Unfriend",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    // trường hợp ko có data => chưa add friend
                    // chưa gửi lời mời

                    return OutlinedButton(
                      onPressed: () {
                        _addFriend(
                            widget.ortherUserData["id"],
                            widget.ortherUserData["email"],
                            widget.ortherUserData["username"]);
                      },
                      child: Center(
                        child: Text(
                          "Add friend",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
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
