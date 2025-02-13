import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class EditTable extends ConsumerStatefulWidget {
  const EditTable(
      {super.key,
      required this.idTask,
      required this.idTable,
      required this.tableName,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.endDateTask,
      required this.uidAdmin,
      required this.taskName});
  final String idTask;
  final String idTable;
  final String tableName;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String endDateTask;
  final String uidAdmin;
  final String taskName;

  @override
  ConsumerState<EditTable> createState() => _EditTableState();
}

class _EditTableState extends ConsumerState<EditTable> {
  final _formkey = GlobalKey<FormState>();
  String? _entertableName = "";
  var _isLoading = false;
  String? _enterStartDate;
  String? _enterEndDate;
  String? _enterStartTime;
  String? _enterEndTime;
  @override
  void initState() {
    _entertableName = widget.tableName;
    _enterStartDate = widget.startDate;
    _enterStartTime = widget.startTime;
    _enterEndDate = widget.endDate;
    _enterEndTime = widget.endTime;
    super.initState();
  }

  void _removeTable() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .doc(widget.idTable)
          .delete();

// tính toán lại phần trăm hoàn thành

      // gửi thông báo cho toàn bộ user trong task
      final allUserInTask = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("users")
          .get();
      for (final user in allUserInTask.docs) {
        addNotification(
          uidUser: user.id,
          redirect: "all_table",
          type: "remove_table",
          content: "Table $_entertableName is remove!",
          by: ref.read(userData)["email"],
          idTask: widget.idTask,
          uidAdmin: widget.uidAdmin,
        );
      }

      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .snapshots()
          .listen((tablesSnapshot) async {
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
        }

        double percentAllTask =
            totalCards == 0 ? 1.0 : totalCompletedCards / totalCards;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uidAdmin)
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
              .doc(widget.uidAdmin)
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
              uidAdmin: widget.uidAdmin,
            );
          }
        }
      });

      Navigator.of(context).pop("Success");
    } catch (e) {
      Navigator.of(context).pop("Err: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

// tạo task
  void _EditTable() async {
    FocusScope.of(context).unfocus();
    final validate = _formkey.currentState!.validate();
    if (!validate) {
      return;
    }
    _formkey.currentState!.save();

// load lại hàm build
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      if (_enterStartDate != "No date" && _enterEndDate != "No date") {
        DateTime startDate = DateFormat("dd/MM/yyyy").parse(_enterStartDate!);
        DateTime startTime = _enterStartTime != "No time"
            ? DateFormat("HH:mm").parse(_enterStartTime!)
            : DateTime(2000, 1, 1); // nếu thời gian = null gán mặc định (00:00)

        DateTime endDate = DateFormat("dd/MM/yyyy").parse(_enterEndDate!);
        DateTime endTime = _enterEndTime != "No time"
            ? DateFormat("HH:mm").parse(_enterEndTime!)
            : DateTime(2000, 1, 1);

        DateTime fullStartDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          startTime.hour,
          startTime.minute,
        );

        DateTime fullEndDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          endTime.hour,
          endTime.minute,
        );

        if (!fullStartDateTime.isBefore(fullEndDateTime)) {
          throw Exception("The start time must be before the end time!");
        }
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .doc(widget.idTable)
          .set(
        {
          "table_name": _entertableName,
          "start_date": _enterStartDate == "No date" ? null : _enterStartDate,
          "end_date": _enterEndDate == "No date" ? null : _enterEndDate,
          "start_time": _enterStartTime == "No time" ? null : _enterStartTime,
          "end_time": _enterEndTime == "No time" ? null : _enterEndTime,
          "create_at": DateTime.now(),
        },
        SetOptions(
          merge: true,
        ),
      );
// thêm hoạt động vào db
      // gửi thông báo cho toàn bộ user trong task
      final allUserInTask = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("users")
          .get();
      for (final user in allUserInTask.docs) {
        addNotification(
          uidUser: user.id,
          redirect: "all_table",
          type: "leave_task",
          content: "The ${widget.tableName} task has been changed.",
          by: ref.read(userData)["email"],
          idTask: widget.idTask,
          uidAdmin: widget.uidAdmin,
        );
      }
      Navigator.of(context).pop("Success");
    } catch (e) {
      Navigator.of(context).pop("Err: $e");
    }
  }

  void _inputDatePicker(String type, String endDateTask) async {
    final now = DateTime.now();
    final lastDate = endDateTask.isEmpty
        ? DateTime(now.year + 30, now.month, now.day)
        : DateFormat("dd/MM/yyyy").parse(endDateTask);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );

    if (pickedDate == null) return;

    setState(() {
      if (type == "start_date") {
        _enterStartDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      } else if (type == "end_date") {
        _enterEndDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      }
    });
  }

  void _inputTimePicker(String type) async {
    final nowTime = TimeOfDay.now();
    final now = DateTime.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: nowTime,
    );

    if (pickedTime == null) return;
    setState(
      () {
        if (type == "start_time") {
          _enterStartTime = DateFormat('HH:mm').format(DateTime(now.year,
              now.month, now.day, pickedTime.hour, pickedTime.minute));
        } else if (type == "end_time") {
          _enterEndTime = DateFormat('HH:mm').format(DateTime(now.year,
              now.month, now.day, pickedTime.hour, pickedTime.minute));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Theme.of(context).colorScheme.onTertiary,
        ),
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: keyboardSpace + 16,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Task",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Name Input
                    TextFormField(
                      initialValue: _entertableName,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Table Name ...",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _entertableName = value!;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Start Date
                    const Text(
                      "Start Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _inputDatePicker("start_date", widget.endDateTask);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.date_range),
                              const SizedBox(width: 8),
                              Text(_enterStartDate ?? "Select Start Date"),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // chỉ cho chọn giờ khi ngày ko null
                        if (_enterStartDate != null)
                          OutlinedButton(
                            onPressed: () {
                              _inputTimePicker("start_time");
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.timelapse),
                                const SizedBox(width: 8),
                                Text(_enterStartTime ?? "Start Time")
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // End Date
                    const Text(
                      "End Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _inputDatePicker("end_date", widget.endDateTask);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.date_range),
                              const SizedBox(width: 8),
                              Text(_enterEndDate ?? "Select End Date"),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // chỉ cho chọn giờ khi ngày ko null
                        if (_enterEndDate != null)
                          OutlinedButton(
                            onPressed: () {
                              _inputTimePicker("end_time");
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.timelapse),
                                const SizedBox(width: 8),
                                Text(_enterEndTime ?? "End Time")
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _EditTable,
                        child: const Text("Edit"),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: _removeTable,
                        child: const Text(
                          "Remove table",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
