import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  const SearchResultScreen({super.key, required this.searchElement});
  final String searchElement;
  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  String _enterSearch = "";
  final _formSearchKey = GlobalKey<FormState>();
  void _searchElement() {
    if (_formSearchKey.currentState!.validate()) {
      _formSearchKey.currentState!.save();
    }
  }

  @override
  void initState() {
    _enterSearch = widget.searchElement;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("tasks")
          .where(
            "task_name",
            isEqualTo: _enterSearch,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Loading..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Loading..."),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Search result"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.onTertiary,
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formSearchKey,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.black),
                        initialValue: _enterSearch,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          hintText: "Search...",
                          hintStyle: const TextStyle(color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: _searchElement,
                            icon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "You haven't entered anything!";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          print(1);
                          setState(() {
                            print(2);
                            _enterSearch = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Center(
                    child: Text(
                      "None",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final dataTask = snapshot.data!.docs;
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Search task",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // thanh tìm kiếm
                Container(
                  color: Theme.of(context).colorScheme.onTertiary,
                  child: Form(
                    key: _formSearchKey,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.black),
                      initialValue: _enterSearch,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        hintText: "Search...",
                        hintStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: _searchElement,
                          icon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "You haven't entered anything!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          _enterSearch = value.toString();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: SizedBox(
                        child: Text(
                          "Task name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(""),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 8,
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
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: dataTask.length,
                      itemBuilder: (context, idx) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        alignment: Alignment.centerLeft,
                                      ),
                                      onPressed: () {
                                        String uidAdmin =
                                            ref.read(userData)["uid"];
                                        if (dataTask[idx].data()["reference"] !=
                                            null) {
                                          final temp =
                                              dataTask[idx].data()["reference"];
                                          final tempList =
                                              temp.toString().split("/");
                                          uidAdmin = tempList[1];
                                        }
                                        navigatorToAllTable(
                                            context,
                                            dataTask[idx].id,
                                            ref.read(userData)["uid"],
                                            uidAdmin);
                                      },
                                      child: Text(
                                        dataTask[idx].data()["task_name"] ??
                                            "None",
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(""),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 8,
                                  child: SizedBox(
                                    child: Text(
                                      dataTask[idx].data()["end_date"] ??
                                          "No date",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 0.2,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
