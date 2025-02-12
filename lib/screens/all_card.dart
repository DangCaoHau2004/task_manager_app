import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/widget/builder_helper.dart';
import 'package:task_manager_app/widget/add_card.dart';
import 'package:task_manager_app/widget/comment.dart';
import 'package:task_manager_app/widget/edit_table.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class AllCardScreen extends ConsumerStatefulWidget {
  const AllCardScreen(
      {super.key,
      required this.idTask,
      required this.idTable,
      required this.endDateTask,
      required this.idAdmin,
      required this.currentUserData,
      required this.taskName});
  final String idTask;
  final String idTable;
  final String idAdmin;
  final String endDateTask;
  final String taskName;
  final Map<String, dynamic> currentUserData;
  @override
  ConsumerState<AllCardScreen> createState() => _AllCardScreenState();
}

class _AllCardScreenState extends ConsumerState<AllCardScreen> {
  void _completeElement(String idCard) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.idAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .doc(widget.idTable)
          .collection("cards")
          .doc(idCard)
          .set(
        {
          "status": "complete",
        },
        SetOptions(
          merge: true,
        ),
      );

      // tính toán lại tỉ lệ hoàn thành
      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.idAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .snapshots()
          .listen(
        (tablesSnapshot) async {
          double totalCards = 0.0;
          double totalCompletedCards = 0.0;

          for (final table in tablesSnapshot.docs) {
            final allCards = await table.reference.collection("cards").get();

            double countElementInTable = allCards.docs.length.toDouble();
            double countElementInTableComplete = allCards.docs
                .where((card) => card.data()["status"] != null)
                .length
                .toDouble();

            totalCards += countElementInTable;
            totalCompletedCards += countElementInTableComplete;

            // cập nhật status và complete của table
            if (table.id == widget.idTable) {
              double percent = countElementInTable > 0
                  ? (countElementInTableComplete / countElementInTable)
                  : 0.0;

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.idAdmin)
                  .collection("tasks")
                  .doc(widget.idTask)
                  .collection("tables")
                  .doc(widget.idTable)
                  .set(
                {
                  "complete": "${(percent * 100).toStringAsFixed(0)}%",
                  "status": percent == 1.0 ? "Complete" : "Pending"
                },
                SetOptions(merge: true),
              );

              if (percent == 1.0) {
                // thông báo
                // gửi thông báo cho toàn bộ user trong task khi table hoàn thành
                final allUserInTask = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.idAdmin)
                    .collection("tasks")
                    .doc(widget.idTask)
                    .collection("users")
                    .get();
                for (final user in allUserInTask.docs) {
                  addNotification(
                    uidUser: user.id,
                    redirect: "all_table",
                    type: "complete_table",
                    content: "Table ${table.data()["table_name"]} is complete",
                    by: ref.read(userData)["email"],
                    idTask: widget.idTask,
                    uidAdmin: widget.idAdmin,
                  );
                }
              }
            }
          }

          double percentAllTask =
              totalCards == 0 ? 1.0 : totalCompletedCards / totalCards;

          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.idAdmin)
              .collection("tasks")
              .doc(widget.idTask)
              .set(
            {
              "complete": "${(percentAllTask * 100).toStringAsFixed(0)}%",
              "status": percentAllTask == 1.0 ? "Complete" : "Pending"
            },
            SetOptions(merge: true),
          );
          if (percentAllTask == 1.0) {
            // thông báo
            // gửi thông báo cho toàn bộ user trong task khi table hoàn thành
            final allUserInTask = await FirebaseFirestore.instance
                .collection("users")
                .doc(widget.idAdmin)
                .collection("tasks")
                .doc(widget.idTask)
                .collection("users")
                .get();
            for (final user in allUserInTask.docs) {
              addNotification(
                uidUser: user.id,
                redirect: "all_table",
                type: "complete_task",
                content: "Task ${widget.taskName} is complete",
                by: ref.read(userData)["email"],
                idTask: widget.idTask,
                uidAdmin: widget.idAdmin,
              );
            }
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _unCompleteElement(String idCard) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.idAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .doc(widget.idTable)
          .collection("cards")
          .doc(idCard)
          .set(
        {
          "status": null,
        },
        SetOptions(
          merge: true,
        ),
      );
      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.idAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .snapshots()
          .listen(
        (tablesSnapshot) async {
          double totalCards = 0.0;
          double totalCompletedCards = 0.0;

          for (final table in tablesSnapshot.docs) {
            final allCards = await table.reference.collection("cards").get();

            double countElementInTable = allCards.docs.length.toDouble();
            double countElementInTableComplete = allCards.docs
                .where((card) => card.data()["status"] != null)
                .length
                .toDouble();

            totalCards += countElementInTable;
            totalCompletedCards += countElementInTableComplete;

            // cập nhật status và complete của table
            if (table.id == widget.idTable) {
              double percent = countElementInTable > 0
                  ? (countElementInTableComplete / countElementInTable)
                  : 0.0;

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.idAdmin)
                  .collection("tasks")
                  .doc(widget.idTask)
                  .collection("tables")
                  .doc(widget.idTable)
                  .set(
                {
                  "complete": "${(percent * 100).toStringAsFixed(0)}%",
                  "status": percent == 1.0 ? "Complete" : "Pending"
                },
                SetOptions(merge: true),
              );
              if (percent == 1.0) {
                // thông báo
                // gửi thông báo cho toàn bộ user trong task khi table hoàn thành
                final allUserInTask = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.idAdmin)
                    .collection("tasks")
                    .doc(widget.idTask)
                    .collection("users")
                    .get();
                for (final user in allUserInTask.docs) {
                  addNotification(
                    uidUser: user.id,
                    redirect: "all_table",
                    type: "complete_table",
                    content: "Table ${table.data()["table_name"]} is complete",
                    by: ref.read(userData)["email"],
                    idTask: widget.idTask,
                    uidAdmin: widget.idAdmin,
                  );
                }
              }
            }
          }

          double percentAllTask =
              totalCards == 0 ? 1.0 : totalCompletedCards / totalCards;

          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.idAdmin)
              .collection("tasks")
              .doc(widget.idTask)
              .set(
            {
              "complete": "${(percentAllTask * 100).toStringAsFixed(0)}%",
              "status": percentAllTask == 1.0 ? "Complete" : "Pending"
            },
            SetOptions(merge: true),
          );
          if (percentAllTask == 1.0) {
            // thông báo
            // gửi thông báo cho toàn bộ user trong task khi table hoàn thành
            final allUserInTask = await FirebaseFirestore.instance
                .collection("users")
                .doc(widget.idAdmin)
                .collection("tasks")
                .doc(widget.idTask)
                .collection("users")
                .get();
            for (final user in allUserInTask.docs) {
              addNotification(
                uidUser: user.id,
                redirect: "all_table",
                type: "complete_task",
                content: "Task ${widget.taskName} is complete",
                by: ref.read(userData)["email"],
                idTask: widget.idTask,
                uidAdmin: widget.idAdmin,
              );
            }
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showModalBottomCard(String idTask, String idTable) async {
    final res = await showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return AddCard(
            idTask: idTask,
            idTable: idTable,
            uidAdmin: widget.idAdmin,
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

  void _editTable(
    String idTask,
    String idTable,
    String tableName,
    String visibility,
    String startDate,
    String startTime,
    String endDate,
    String endTime,
    String endDateTask,
  ) async {
    final res = await showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return EditTable(
            idTask: idTask,
            idTable: idTable,
            tableName: tableName,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            endDateTask: endDateTask,
            uidAdmin: widget.idAdmin,
            taskName: widget.taskName,
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

  final _keyCommentForm = GlobalKey<FormState>();
  String _enterComment = "";
  var _isLoading = false;
  void _addComment() {
    setState(() {
      _isLoading = true;
    });
  }

  Stream fetchTables() {
    final uid = widget.idAdmin;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .doc(widget.idTask)
        .collection("tables")
        .doc(widget.idTable)
        .snapshots();
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
    return StreamBuilder(
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

        final tableData = snapshot.data!.data();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              tableData?["table_name"] ?? "No name",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                if (tableData == null || tableData.isEmpty)
                  const Center(
                    child: Text(
                      "No data of table",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                if (tableData != null && tableData.isNotEmpty)
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
                                    "Table name:",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            child: Text(
                              tableData["table_name"],
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "Start date:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: Text(
                              (tableData["start_date"] ?? "No date") +
                                  " " +
                                  (tableData["start_time"] ?? ""),
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "End date:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              (tableData["end_date"] ?? "No date") +
                                  " " +
                                  (tableData["start_time"] ?? ""),
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "Status:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: Text(
                              tableData["status"] ?? "None",
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "Complete:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: Text(
                              tableData["complete"] ?? "None",
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
                if (widget.currentUserData["role"] != "member")
                  ElevatedButton(
                    onPressed: () {
                      final tableName = tableData?["table_name"] ?? "None";
                      final visibility = tableData?["visibility"] ?? "None";
                      final startDate = tableData?["start_date"] ?? "No date";
                      final startTime = tableData?["start_time"] ?? "No time";
                      final endDate = tableData?["end_date"] ?? "No date";
                      final endTime = tableData?["end_time"] ?? "No time";

                      _editTable(
                        widget.idTask,
                        widget.idTable,
                        tableName,
                        visibility,
                        startDate,
                        startTime,
                        endDate,
                        endTime,
                        widget.endDateTask,
                      );
                    },
                    child: const Text(
                      "Edit table",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "Card of table",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 8,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.idAdmin)
                      .collection("tasks")
                      .doc(widget.idTask)
                      .collection("tables")
                      .doc(widget.idTable)
                      .collection("cards")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return errorWidget(snapshot.error.toString(), "");
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No card of table",
                        style: TextStyle(fontSize: 16),
                      );
                    }
                    final dataTable = snapshot.data!.docs;
                    List dataNotComplete = [];
                    List dataComplete = [];
                    for (final i in dataTable) {
                      if (i.data()["status"] == null) {
                        dataNotComplete.add({
                          "card_name": i.data()["card_name"],
                          "id": i.id,
                        });
                        continue;
                      }
                      dataComplete.add({
                        "card_name": i.data()["card_name"],
                        "id": i.id,
                      });
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dataNotComplete.isEmpty)
                          const Center(
                            child: Text(
                              "No card of table",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                        if (dataNotComplete.isNotEmpty)
                          // danh sách các card chưa hoàn thành
                          ...dataNotComplete.map(
                            (data) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLow,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              data["card_name"] ?? "None",
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              _completeElement(data["id"]);
                                            },
                                            icon: const Icon(
                                              Icons.circle_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(
                          height: 40,
                        ),
                        const Text(
                          "Card complete of table",
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (dataComplete.isEmpty)
                          const Center(
                            child: Text(
                              "No card of table",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        // danh sách các card đã hoàn thành
                        if (dataComplete.isNotEmpty)
                          ...dataComplete.map(
                            (data) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerLow,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              data["card_name"] ?? "None",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              _unCompleteElement(data["id"]);
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 100,
                ),
                // comment
                Comment(
                  uidAdmin: widget.idAdmin,
                  idTable: widget.idTable,
                  idTask: widget.idTask,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              _showModalBottomCard(widget.idTask, widget.idTable);
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        );
      },
    );
  }
}
