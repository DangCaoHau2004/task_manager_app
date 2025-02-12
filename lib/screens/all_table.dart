import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/add_table.dart';
import 'package:task_manager_app/widget/builder_helper.dart';
import 'package:task_manager_app/widget/comment.dart';
import 'package:task_manager_app/widget/edit_task.dart';

class AllTableScreen extends ConsumerStatefulWidget {
  const AllTableScreen({
    super.key,
    required this.idTask,
    required this.uidCurrentUser,
    required this.uidAdmin,
  });
  final String idTask;

  final String uidCurrentUser;
  final String uidAdmin;
  @override
  ConsumerState<AllTableScreen> createState() => _AllTableScreenState();
}

class _AllTableScreenState extends ConsumerState<AllTableScreen> {
  void _showModalBottomTable(
      String idTask, String endDate, String uidAdmin) async {
    final res = await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return AddTable(
          idTask: idTask,
          endDate: endDate,
          uidAdmin: uidAdmin,
        );
      },
    );
    if (res == null) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
  }

  void _editTask(
      String idTask,
      String taskName,
      String visibility,
      String startDate,
      String startTime,
      String endDate,
      String endTime) async {
    final res = await showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return EditTask(
            idTask: idTask,
            taskName: taskName,
            visibility: visibility,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            uidAdmin: widget.uidAdmin,
          );
        });
    if (res == null) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
  }

  var _isLoading = false;

  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchTables() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uidAdmin)
        .collection("tasks")
        .doc(widget.idTask)
        .snapshots();
  }

  void _deleteTask(idTask, idAdmin, taskName) async {
    setState(() {
      _isLoading = true;
    });

    final allUserInTask = await FirebaseFirestore.instance
        .collection("users")
        .doc(idAdmin)
        .collection("tasks")
        .doc(idTask)
        .collection("users")
        .get();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(idAdmin)
        .collection("tasks")
        .doc(idTask)
        .delete();

    for (final user in allUserInTask.docs) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .collection("tasks")
          .doc(idTask)
          .delete();
      addNotification(
        uidUser: user.id,
        redirect: "all_task",
        type: "remove_task",
        content: "Remove task: $taskName",
        by: ref.read(userData)["email"],
      );
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Success"),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
    navigatorToAllTask(context);
  }

  void _leaveTask(idTask, idAdmin, idCurrentUser, taskName) async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(idAdmin)
        .collection("tasks")
        .doc(idTask)
        .collection("users")
        .doc(idCurrentUser)
        .delete();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(idCurrentUser)
        .collection("tasks")
        .doc(idTask)
        .delete();

    // gửi thông báo cho toàn bộ user trong task
    final allUserInTask = await FirebaseFirestore.instance
        .collection("users")
        .doc(idAdmin)
        .collection("tasks")
        .doc(idTask)
        .collection("users")
        .get();
    for (final user in allUserInTask.docs) {
      addNotification(
        uidUser: user.id,
        redirect: "all_table",
        type: "leave_task",
        content:
            "${ref.read(userData)["username"]} has left the task($taskName)",
        by: ref.read(userData)["email"],
        idTask: idTask,
        uidAdmin: idAdmin,
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Success"),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
    navigatorToAllTask(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading..."),
        ),
        body: loadingWidget(""),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: fetchTables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Loading..."),
            ),
            body: loadingWidget(""),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body: errorWidget(snapshot.error.toString(), ""),
          );
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("No Data"),
            ),
            body: const Center(
              child: Text(
                "No recent tasks available.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        final taskData = snapshot.data!.data();
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(widget.uidAdmin)
              .collection("tasks")
              .doc(widget.idTask)
              .collection("users")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Loading..."),
                ),
                body: loadingWidget(""),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Error"),
                ),
                body: errorWidget(snapshot.error.toString(), ""),
              );
            } else if (!snapshot.hasData || !snapshot.data!.docs.isNotEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("No Data"),
                ),
                body: const Center(
                  child: Text(
                    "No recent tasks available.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            final allUser = snapshot.data!.docs;
            var currentUserData;
            for (final user in allUser) {
              if (user.id == widget.uidCurrentUser) {
                currentUserData = user.data();
              }
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  taskData?["task_name"] ?? "No name",
                ),
              ),
              endDrawer: taskData?["visibility"] == "Private"
                  ? null
                  : Drawer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 90,
                            child: DrawerHeader(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    taskData?["task_name"] ?? "No name",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (currentUserData != null &&
                              currentUserData["role"] != "member")
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  navigatorToAddUser(
                                    context,
                                    {
                                      "create_at": taskData?["create_at"],
                                      "end_date": taskData?["end_date"],
                                      "end_time": taskData?["end_time"],
                                      "start_date": taskData?["start_date"],
                                      "start_time": taskData?["start_time"],
                                      "task_name": taskData?["task_name"],
                                      "visibility": taskData?["visibility"],
                                      "id": widget.idTask,
                                    },
                                    currentUserData,
                                    allUser,
                                    widget.uidAdmin,
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.add),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "Add user",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                navigatorToAllUser(
                                  context,
                                  {
                                    "create_at": taskData?["create_at"],
                                    "end_date": taskData?["end_date"],
                                    "end_time": taskData?["end_time"],
                                    "start_date": taskData?["start_date"],
                                    "start_time": taskData?["start_time"],
                                    "task_name": taskData?["task_name"],
                                    "visibility": taskData?["visibility"],
                                    "id": widget.idTask,
                                  },
                                  currentUserData,
                                  widget.uidAdmin,
                                  allUser,
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.list_alt),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "All user",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (currentUserData != null &&
                              currentUserData["role"] == "admin")
                            Container(
                              padding: const EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  _deleteTask(widget.idTask, widget.uidAdmin,
                                      taskData?["task_name"]);
                                },
                                child: const Text(
                                  "Delete task",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ),
                            ),
                          if (currentUserData != null &&
                              currentUserData["role"] != "admin")
                            Container(
                              padding: const EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  _leaveTask(
                                      widget.idTask,
                                      widget.uidAdmin,
                                      widget.uidCurrentUser,
                                      taskData?["task_name"]);
                                },
                                child: const Text(
                                  "Leave task",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    if (taskData == null || taskData.isEmpty)
                      const Center(
                        child: Text(
                          "No data of task",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    if (taskData != null && taskData.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      "Task name:",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  taskData["task_name"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Start date:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  (taskData["start_date"] ?? "No date") +
                                      " " +
                                      (taskData["start_time"] ?? ""),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "End date:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  (taskData["end_date"] ?? "No date") +
                                      " " +
                                      (taskData["end_time"] ?? ""),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Visibility:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  (taskData["visibility"] ?? "None"),
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Status:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  taskData["status"] ?? "None",
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Complete:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  taskData["complete"] ?? "None",
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (currentUserData != null &&
                        currentUserData["role"] != "member")
                      ElevatedButton(
                        onPressed: () {
                          final taskName = taskData?["task_name"] ?? "None";
                          final visibility = taskData?["visibility"] ?? "None";
                          final startDate =
                              taskData?["start_date"] ?? "No date";
                          final startTime =
                              taskData?["start_time"] ?? "No time";
                          final endDate = taskData?["end_date"] ?? "No date";
                          final endTime = taskData?["end_time"] ?? "No time";

                          _editTask(widget.idTask, taskName, visibility,
                              startDate, startTime, endDate, endTime);
                        },
                        child: const Text(
                          "Edit task",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (taskData?["visibility"] == "Private")
                      TextButton(
                        onPressed: () {
                          _deleteTask(widget.idTask, widget.uidAdmin,
                              taskData?["task_name"]);
                        },
                        child: const Text(
                          "Delete task",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            child: Text(
                              "Table name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            child: Text(
                              "End date",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.uidAdmin)
                          .collection("tasks")
                          .doc(widget.idTask)
                          .collection("tables")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return errorWidget(snapshot.error.toString(), "");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text(
                            "No table of task",
                            style: TextStyle(fontSize: 16),
                          );
                        }
                        final dataTable = snapshot.data!.docs;
                        return Column(
                          children: [
                            ...dataTable.map((data) {
                              return TextButton(
                                onPressed: () {
                                  final endDateTask =
                                      data.data()["end_date"] ?? "";
                                  navigatorToAllCard(
                                    context,
                                    widget.idTask,
                                    data.id,
                                    endDateTask,
                                    widget.uidAdmin,
                                    taskData?["task_name"],
                                    currentUserData,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        child: Text(
                                          data.data()["table_name"] ?? "None",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        child: Text(
                                          data.data()["end_date"] ?? "No date",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 100,
                    ),

                    // comment
                    Comment(
                      idTable: "",
                      idTask: widget.idTask,
                      uidAdmin: widget.uidAdmin,
                    ),
                  ],
                ),
              ),
              floatingActionButton: (currentUserData != null &&
                      currentUserData["role"] != "member")
                  ? FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        final endDate = taskData?["end_date"] ?? "";
                        _showModalBottomTable(
                            widget.idTask, endDate, widget.uidAdmin);
                      },
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
