import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/builder_helper.dart';

class AllTaskScreen extends ConsumerStatefulWidget {
  const AllTaskScreen({super.key});
  @override
  ConsumerState<AllTaskScreen> createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends ConsumerState<AllTaskScreen> {
  final _formSearchKey = GlobalKey<FormState>();
  final _listSortName = ["End date", "Start date", "Name"];
  String sortData = "end_date";
  bool sortDescending = false;
  String _enterSort = "End date";
  String? _enterSearch;
  bool _isSearchHidden = true;

  void _searchElement() {
    if (_formSearchKey.currentState!.validate()) {
      _formSearchKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        Column(
          children: [
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      icon: sortDescending
                          ? const Icon(Icons.keyboard_arrow_down)
                          : const Icon(Icons.keyboard_arrow_up),
                      value: _enterSort,
                      items: _listSortName.map((sort) {
                        return DropdownMenuItem(
                          value: sort,
                          child: Text(sort),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          if (_enterSort == value) {
                            setState(() {
                              sortDescending = !sortDescending;
                            });
                          } else {
                            setState(
                              () {
                                _enterSort = value;
                                sortData = _enterSort == "End date"
                                    ? "end_date"
                                    : _enterSort == "Start date"
                                        ? "start_date"
                                        : "task_name";
                                print(sortData);
                              },
                            );
                          }
                        }
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
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearchHidden = !_isSearchHidden;
                            });
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ô nhập tìm kiếm
            if (!_isSearchHidden)
              Form(
                key: _formSearchKey,
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    hintText: "Search...",
                    suffixIcon: IconButton(
                      onPressed: _searchElement,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Bạn chưa nhập!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enterSearch = value;
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Chia thành 2 cột (Task Name, End date)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      child: Text(
                        "Task name",
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
            ),
            const SizedBox(
              height: 24,
            ),

            // Các phần tử task ở đây
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(ref.watch(userData)["uid"])
                  .collection("tasks")
                  .orderBy(sortData, descending: sortDescending)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return errorWidget(snapshot.error.toString(), "");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingWidget("");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return noElementWidget("");
                }

                var tasks = snapshot.data!.docs;

                return Column(
                  children: [
                    ...tasks.map((task) {
                      var data = task.data();

                      if (task.data()["reference"] != null) {
                        final dataTask =
                            task.data()["reference"].toString().split("/");
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(dataTask[1])
                              .collection("tasks")
                              .doc(dataTask[3])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                children: [
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 0.2,
                                    width: double.infinity,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Column(
                                children: [
                                  Text(snapshot.error.toString()),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 0.2,
                                    width: double.infinity,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.data() == null ||
                                snapshot.data!.data()!.isEmpty) {
                              return Column(
                                children: [
                                  const Text("No task!"),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 0.2,
                                    width: double.infinity,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }
                            final subData = snapshot.data!.data()!;
                            return TextButton(
                              onPressed: () {
                                navigatorToAllTable(
                                  context,
                                  snapshot.data!.id,
                                  ref.read(userData)["uid"],
                                  dataTask[1],
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          subData["task_name"] ?? "No Name",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          subData["end_date"] ?? "No Date",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 0.2,
                                    width: double.infinity,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      return TextButton(
                        onPressed: () {
                          navigatorToAllTable(
                            context,
                            task.id,
                            ref.read(userData)["uid"],
                            ref.read(userData)["uid"],
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    data["task_name"] ?? "No Name",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    data["end_date"] ?? "No Date",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 0.2,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ]),
    );
  }
}
