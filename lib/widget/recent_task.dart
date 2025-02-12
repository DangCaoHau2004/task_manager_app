import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/builder_helper.dart';

class RecentTask extends ConsumerStatefulWidget {
  const RecentTask({super.key});

  @override
  ConsumerState<RecentTask> createState() => _RecentTaskState();
}

class _RecentTaskState extends ConsumerState<RecentTask> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("tasks")
          .orderBy("create_at", descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget("Recent Project");
        } else if (snapshot.hasError) {
          return errorWidget(snapshot.error.toString(), "Recent Project");
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return noElementWidget("Recent Project");
        } else {
          return recentTaskListWidget(
              snapshot.data!.docs, context, ref.read(userData)["uid"]);
        }
      },
    );
  }
}

Widget recentTaskListWidget(
    List<DocumentSnapshot> tasks, BuildContext context, String uidCurrentUser) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              "Recent Project",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                navigatorToAllTask(context);
              },
              child: const Text("View all"),
            ),
          ],
        ),
      ),
      SizedBox(
        width: double.infinity,
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tasks.length,
          itemBuilder: (ctx, index) {
            final task = tasks[index].data() as Map<String, dynamic>;

            if (task["reference"] != null) {
              final dataTask = task["reference"].toString().split("/");
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(dataTask[1])
                      .collection("tasks")
                      .doc(dataTask[3])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _cardOfRecentTask(context, "Loading", "Loading",
                          null, null, null, true);
                    } else if (snapshot.hasError) {
                      return _cardOfRecentTask(
                          context, "Error", "Error", null, null, null);
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data()!.isEmpty) {
                      return _cardOfRecentTask(
                          context, "No name", "No name", null, null, null);
                    }
                    String taskTitle =
                        snapshot.data!.data()!["task_name"] ?? "None";
                    String taskDate =
                        snapshot.data!.data()!["start_date"] ?? "No date";
                    return _cardOfRecentTask(context, taskTitle, taskDate,
                        dataTask[3], uidCurrentUser, dataTask[1]);
                  });
            }

            String taskTitle = task['task_name'] ?? 'No Title';
            String taskDate = task['start_date'] ?? 'No Date';

            return _cardOfRecentTask(context, taskTitle, taskDate,
                tasks[index].id, uidCurrentUser, uidCurrentUser);
          },
        ),
      ),
    ],
  );
}

Widget _cardOfRecentTask(
    context, taskTitle, taskDate, idTask, uidCurrentUser, uidAdmin,
    [isLoading = false]) {
  return Card(
    color: Theme.of(context).colorScheme.onTertiary,
    margin: const EdgeInsets.only(left: 8.0, right: 8.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (!isLoading)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        taskTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (idTask != null) {
                          navigatorToAllTable(
                              context, idTask, uidCurrentUser, uidAdmin);
                        }
                      },
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
              if (!isLoading)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).colorScheme.onTertiary),
                          const SizedBox(width: 8),
                          Text(taskDate,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
