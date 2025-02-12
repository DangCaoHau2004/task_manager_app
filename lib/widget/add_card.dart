import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/add_notification.dart';

class AddCard extends ConsumerStatefulWidget {
  const AddCard({
    super.key,
    required this.idTask,
    required this.idTable,
    required this.uidAdmin,
  });
  final String idTask;
  final String idTable;
  final String uidAdmin;
  @override
  ConsumerState<AddCard> createState() => _AddCardState();
}

class _AddCardState extends ConsumerState<AddCard> {
  final _formkey = GlobalKey<FormState>();

  var _enterTableName = "";
  var _isLoading = false;

// tạo card
  void _createCard() async {
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
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uidAdmin)
          .collection("tasks")
          .doc(widget.idTask)
          .collection("tables")
          .doc(widget.idTable)
          .collection("cards")
          .add(
        {
          "card_name": _enterTableName,
          "status": null,
          "create_at": DateTime.now(),
        },
      );

      // thông báo
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
          type: "add_card",
          content: "The $_enterTableName card has been added.",
          by: ref.read(userData)["email"],
          idTask: widget.idTask,
          uidAdmin: widget.uidAdmin,
        );
      }
      setState(
        () {
          _isLoading = false;
        },
      );

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

          // cập nhật status và complete của table
          if (table.id == widget.idTable) {
            double percent = countElementInTable > 0
                ? (countElementInTableComplete / countElementInTable)
                : 0.0;

            await FirebaseFirestore.instance
                .collection("users")
                .doc(widget.uidAdmin)
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
          }
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
      });

      Navigator.of(context).pop("Success");
    } catch (e) {
      Navigator.of(context).pop("Err: $e");
    }
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
                "Create Card",
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Card Name ...",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Must not be empty!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterTableName = value!;
                      },
                    ),
                    const SizedBox(
                      height: 200,
                    ),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _createCard,
                        child: const Text("Create"),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
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
