import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class EditTask extends ConsumerStatefulWidget {
  const EditTask({
    super.key,
    required this.idTask,
    required this.taskName,
    required this.visibility,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.uidAdmin,
  });
  final String idTask;
  final String taskName;
  final String visibility;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String uidAdmin;
  @override
  ConsumerState<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends ConsumerState<EditTask> {
  final _formkey = GlobalKey<FormState>();
  String _enterVisibility = "Public";
  String? _enterTaskName = "";
  var _isLoading = false;
  String? _enterStartDate;
  String? _enterEndDate;
  String? _enterStartTime;
  String? _enterEndTime;
  final List<String> _listVisibility = ["Public", "Private"];
  @override
  void initState() {
    _enterTaskName = widget.taskName;
    _enterVisibility = widget.visibility;
    _enterStartDate = widget.startDate;
    _enterStartTime = widget.startTime;
    _enterEndDate = widget.endDate;
    _enterEndTime = widget.endTime;
    super.initState();
  }

// tạo task
  void _editTask() async {
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
          .doc(
            widget.uidAdmin,
          )
          .collection("tasks")
          .doc(widget.idTask)
          .set(
        {
          "task_name": _enterTaskName,
          "visibility": _enterVisibility,
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
// thêm thông báo động vào db
      setState(
        () {
          _isLoading = false;
        },
      );

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
          type: "edit_task",
          content: "The ${widget.taskName} task has been changed.",
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

  void _inputDatePicker(String type) async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 30, now.month, now.day);
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
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      height: MediaQuery.of(context).size.height * 0.75,
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
                      initialValue: _enterTaskName,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Task Name ...",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterTaskName = value!;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Visibility
                    const Text(
                      "Visibility",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField(
                      value: _enterVisibility,
                      items: _listVisibility.map((itemVisibility) {
                        return DropdownMenuItem(
                          value: itemVisibility,
                          child: Text(itemVisibility),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _enterVisibility = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
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
                            _inputDatePicker("start_date");
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
                            _inputDatePicker("end_date");
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
                        onPressed: _editTask,
                        child: const Text("Edit"),
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
