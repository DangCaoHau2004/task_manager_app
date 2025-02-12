import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NotificationScreenState();
  }
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("notifications")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "You don't have notification",
            ),
          );
        }
        final dataNotif = snapshot.data!.docs;
        return ListView.builder(
          itemCount: dataNotif.length,
          itemBuilder: (context, idx) {
            return Container(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  side: BorderSide(width: 0.1),
                ),
                child: TextButton(
                  onPressed: () {
                    if (dataNotif[idx]["redirect"] == "all_table") {
                      navigatorToAllTable(
                          context,
                          dataNotif[idx]["id_task"],
                          ref.read(userData)["uid"],
                          dataNotif[idx]["uidAdmin"]);
                    }
                    if (dataNotif[idx]["redirect"] == "all_task") {
                      navigatorToAllTask(context);
                    }
                    if (dataNotif[idx]["redirect"] == "list_friend") {
                      navigatorToListFriend(context);
                    }
                    if (dataNotif[idx]["redirect"] == "detail_chat") {
                      navigatorToChat(context, dataNotif[idx]["uid"]);
                    }
                  },
                  child: ListTile(
                    title: Text(
                      dataNotif[idx]["content"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                            dataNotif[idx]["create_at"].toDate(),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text("By: ${dataNotif[idx]["by"]}"),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
