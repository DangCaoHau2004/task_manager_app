import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({super.key});
  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(ref.read(userData)["uid"])
            .collection("chats")
            .orderBy("create_at", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Text("You need to add a friend first to receive messages."),
                ],
              ),
            );
          }
          final idChats = [
            ...snapshot.data!.docs.map(
              (chat) {
                return chat["id"];
              },
            ),
          ];
          final ortherUsername = [
            ...snapshot.data!.docs.map(
              (chat) {
                return chat["username"];
              },
            ),
          ];
          final idOrtherUser = [...snapshot.data!.docs.map((data) => data.id)];
          return ListView.builder(
              itemCount: idChats.length,
              itemBuilder: (context, idx) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chats")
                        .doc(idChats[idx])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Card(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 24,
                              ),
                              ListTile(
                                title: Text('Error'),
                                subtitle: Text('Error'),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Card(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 24,
                              ),
                              ListTile(
                                title: Text('None'),
                                subtitle: Text('None'),
                              ),
                            ],
                          ),
                        );
                      }
                      final String lastChatData =
                          snapshot.data!.data()!["last_message"] ?? "";
                      final String lastUidUserChat =
                          snapshot.data!.data()!["uid"] ??
                              ref.read(userData)["uid"];
                      final bool isRead =
                          snapshot.data!.data()!["is_read"] ?? true;
                      Widget leadingInListTile = const Text("");

                      // nếu như người đang có trạng thái chưa đọc và người gửi cuối ko là mình thì hiển thị chấm đỏ
                      if (!isRead &&
                          lastUidUserChat != ref.read(userData)["uid"]) {
                        leadingInListTile = const Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 15,
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {
                            navigatorToChat(
                              context,
                              idOrtherUser[idx],
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(
                                width: 0.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: leadingInListTile,
                                  title: Text(ortherUsername[idx]),
                                  subtitle: Text(
                                    lastChatData.isEmpty
                                        ? "None"
                                        : lastChatData,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              });
        },
      ),
    );
  }
}
