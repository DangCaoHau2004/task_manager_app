import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/utils/add_notification.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class DetailChat extends ConsumerStatefulWidget {
  const DetailChat({super.key, required this.uidOrtherUser});
  final String uidOrtherUser;

  @override
  ConsumerState<DetailChat> createState() => _DetailChatState();
}

class _DetailChatState extends ConsumerState<DetailChat> {
  final _keyCommentForm = GlobalKey<FormState>();
  String _enterMessage = "";
  final _commentController = TextEditingController();
  // Hàm gửi tin nhắn
  void _addMessage(String idChat) async {
    if (_keyCommentForm.currentState!.validate()) {
      _keyCommentForm.currentState!.save();
      try {
        await FirebaseFirestore.instance
            .collection("chats")
            .doc(idChat)
            .collection("chat")
            .add({
          "uid": ref.read(userData)["uid"],
          "create_at": DateTime.now(),
          "content": _enterMessage,
        });
        FirebaseFirestore.instance.collection("chats").doc(idChat).update({
          "last_message": _enterMessage,
          "is_read": false,
          "create_at": DateTime.now(),
          "uid": ref.read(userData)["uid"],
        });

        // cập nhật thời gian thay đổi trong truy vấn chính
        FirebaseFirestore.instance
            .collection("users")
            .doc(ref.read(userData)["uid"])
            .collection("chats")
            .doc(widget.uidOrtherUser)
            .update(
          {
            "create_at": DateTime.now(),
          },
        );
        // cập nhật thông báo cho user kia được nhận tin nhắn
        addNotification(
          uidUser: widget.uidOrtherUser,
          redirect: "detail_chat",
          content: "You have a message from " + ref.read(userData)["username"],
          type: "chat",
          by: ref.read(userData)["email"],
          uid: ref.read(userData)["uid"],
        );

        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = ref.read(userData)["uid"];

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("chats")
          .doc(widget.uidOrtherUser)
          .snapshots(),
      builder: (context, snapshot) {
        // Đợi dữ liệu từ Firestore
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Kiểm tra nếu không có dữ liệu
        if (!snapshot.hasData ||
            snapshot.data?.data() == null ||
            snapshot.data!.data()!.toString().isEmpty) {
          return const Scaffold(
            body: Center(
              child:
                  Text("You need to add a friend first to receive messages."),
            ),
          );
        }

        final chatData = snapshot.data!.data() as Map<String, dynamic>;
        final String ortherUsername = chatData["username"] ?? "Unknown";
        final String idChat = chatData["id"] ?? "";

        return Scaffold(
          appBar: AppBar(
            title: Text(ortherUsername),
            actions: [
              IconButton(
                  onPressed: () {
                    final ortherUserData = {
                      "username": ortherUsername,
                      "email": chatData["email"],
                      "id": widget.uidOrtherUser,
                    };
                    navigatorToOrtherUser(
                        context, ortherUserData, ref.read(userData)["uid"]);
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .doc(idChat)
                .collection("chat")
                .orderBy("create_at", descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Nếu không có tin nhắn
              if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No messages yet."),
                );
              }

              final messages = chatSnapshot.data!.docs;
              // nếu như người gửi cuối cùng không phải ta, đổi thành đã đọc tin nhắn
              FirebaseFirestore.instance
                  .collection("chats")
                  .doc(idChat)
                  .snapshots()
                  .listen((data) {
                if (data.data()!["uid"] != ref.read(userData)["uid"]) {
                  FirebaseFirestore.instance
                      .collection("chats")
                      .doc(idChat)
                      .update(
                    {
                      "is_read": true,
                    },
                  );
                }
              });

              return ListView.builder(
                itemCount: messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final msg = messages[index].data();
                  // nếu như người gửi là mình
                  if (ref.read(userData)["uid"] == msg["uid"]) {
                    return ListTile(
                      trailing: CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            const AssetImage("assets/images/user.png"),
                        backgroundColor:
                            Theme.of(context).colorScheme.onTertiary,
                      ),
                      title: Text(
                        msg["content"] ?? "",
                        textAlign: TextAlign.end,
                      ),
                      subtitle: Text(
                        msg["create_at"] != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(msg["create_at"].toDate())
                            : "N/A",
                        textAlign: TextAlign.end,
                      ),
                    );
                  }
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundImage:
                          const AssetImage("assets/images/user.png"),
                      backgroundColor: Theme.of(context).colorScheme.onTertiary,
                    ),
                    title: Text(
                      msg["content"] ?? "",
                    ),
                    subtitle: Text(
                      msg["create_at"] != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(msg["create_at"].toDate())
                          : "N/A",
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: Form(
            key: _keyCommentForm,
            child: TextFormField(
              controller: _commentController,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(0),
                  ),
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: "Message...",
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                suffixIcon: IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _addMessage(idChat),
                  icon: const Icon(Icons.send),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Bạn chưa nhập!";
                }
                return null;
              },
              onSaved: (value) => _enterMessage = value.toString(),
            ),
          ),
        );
      },
    );
  }
}
