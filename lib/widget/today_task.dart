import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/builder_helper.dart';

class TodayTask extends ConsumerStatefulWidget {
  const TodayTask({super.key});

  @override
  ConsumerState<TodayTask> createState() => _TodayTaskState();
}

class _TodayTaskState extends ConsumerState<TodayTask> {
  // Stream<double> _averageCompleteElementStream(String idTask, String idAdmin) {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(idAdmin)
  //       .collection("tasks")
  //       .doc(idTask)
  //       .collection("tables")
  //       .snapshots()
  //       .asyncMap((table) async {
  //     double countElement = 0.0;
  //     double countElementComplete = 0.0;

  //     if (table.docs.isEmpty) {
  //       return 1.0;
  //     }

  //     for (final table in table.docs) {
  //       final allCard = await table.reference.collection("cards").get();
  //       if (allCard.docs.isEmpty) {
  //         continue;
  //       }

  //       for (final card in allCard.docs) {
  //         countElement += 1;
  //         if (card.data()["status"] != null) {
  //           countElementComplete += 1;
  //         }
  //       }
  //     }

  //     return countElement == 0 ? 1.0 : countElementComplete / countElement;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(ref.watch(userData)["uid"])
            .collection("tasks")
            .where(
              "start_date",
              isLessThanOrEqualTo: DateFormat('dd/MM/yyyy').format(
                DateTime.now(),
              ),
            )
            .where(
              "end_date",
              isGreaterThanOrEqualTo: DateFormat('dd/MM/yyyy').format(
                DateTime.now(),
              ),
            )
            .orderBy("create_at", descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget("Today Task");
          } else if (snapshot.hasError) {
            return errorWidget(snapshot.error.toString(), "Today Task");
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return _buildTodayProject(snapshot.data!.docs);
          }

          return noElementWidget("Today Task");
        });
  }

  Widget _buildTodayProject(List<DocumentSnapshot> projectData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                "Today Project",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
        Column(
          children: projectData.map((project) {
            final task = project.data() as Map<String, dynamic>;
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
                      return _todayTaskCard({
                        "task_name": "Loading...",
                        "start_date": "Loading...",
                        "end_date": "Loading",
                        "start_time": "",
                        "end_time": "",
                      }, null, null, null);
                    } else if (snapshot.hasError) {
                      return _todayTaskCard({
                        "task_name": "Loading...",
                        "start_date": "Loading...",
                        "end_date": "Loading",
                        "start_time": "",
                        "end_time": "",
                      }, null, null, null);
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data()!.isEmpty) {
                      return _todayTaskCard({
                        "task_name": "Loading...",
                        "start_date": "Loading...",
                        "end_date": "Loading",
                        "start_time": "",
                        "end_time": "",
                      }, null, null, null);
                    }
                    final taskData = snapshot.data!.data();
                    return _todayTaskCard(taskData, project,
                        ref.read(userData)["uid"], dataTask[1]);
                  });
            }
            return _todayTaskCard(task, project, ref.read(userData)["uid"],
                ref.read(userData)["uid"]);
          }).toList(),
        ),
      ],
    );
  }

  Widget _todayTaskCard(task, project, uidCurrentUser, uidAdmin) {
    final percent = task != null
        ? int.parse(task["complete"].toString().replaceAll("%", ""))
        : 1.0;
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  task['task_name'] ?? "Loading...",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    navigatorToAllTable(
                        context, project.id, uidCurrentUser, uidAdmin);
                  },
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Start at: ${task['start_date'] ?? "Loading..."} ${task['start_time'] ?? ""}"),
                    Text(
                        "End at: ${task['end_date'] ?? "Loading..."} ${task['end_time'] ?? ""}"),
                  ],
                ),
                if (project != null)
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 5.0,
                    percent: percent / 100,
                    backgroundColor: Theme.of(context).colorScheme.onTertiary,
                    progressColor: Theme.of(context).colorScheme.primary,
                    center: Text(
                      "${(percent).toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 16),
                    ),
                    animation: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
