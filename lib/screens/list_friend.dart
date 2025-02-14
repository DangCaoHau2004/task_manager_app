import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';

class ListFriend extends ConsumerStatefulWidget {
  const ListFriend({super.key});

  @override
  ConsumerState<ListFriend> createState() => _ListFriendState();
}

class _ListFriendState extends ConsumerState<ListFriend> {
  final _formSearchKey = GlobalKey<FormState>();
  var _isSearching = false;
  var _isLoading = false;
  var _enterSearch;

  void _acceptFriendRequest(
      uid, String nameOrtherUser, String emailOrtherUser) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(ref.read(userData)["uid"])
          .set(
        {"status": "friend"},
        SetOptions(
          merge: true,
        ),
      );
      final idChat = await FirebaseFirestore.instance.collection("chats").add({
        "last_message": null,
        "is_read": null,
        "create_at": DateTime.now(),
        "uid": null,
      });
// thêm thông tin user vào đoạn chat
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("chats")
          .doc(ref.read(userData)["uid"])
          .set(
        {
          "username": ref.read(userData)["username"],
          "create_at": DateTime.now(),
          "id": idChat.id,
          "email": ref.read(userData)["email"],
        },
        SetOptions(
          merge: true,
        ),
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("friends")
          .doc(uid)
          .set(
        {"status": "friend"},
        SetOptions(
          merge: true,
        ),
      );
      // thêm thông tin user vào đoạn chat
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("chats")
          .doc(uid)
          .set(
        {
          "username": nameOrtherUser,
          "create_at": DateTime.now(),
          "id": idChat.id,
          "email": emailOrtherUser,
        },
        SetOptions(
          merge: true,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  void _searchElement(Function setStateModal) {
    FocusScope.of(context).unfocus();

    final isValid = _formSearchKey.currentState!.validate();
    if (!isValid) {
      setStateModal(() {
        _isSearching = false;
      });
      return;
    }
    _formSearchKey.currentState!.save();
    setStateModal(() {
      _isSearching = true;
    });
  }

  void _showModalBottomSearch() async {
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.75,
              child: ListView(
                children: [
                  // Thanh tìm kiếm
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formSearchKey,
                      child: TextFormField(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          hintText: "Email...",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              _searchElement(setStateModal);
                            },
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Please enter corectly!";
                          }
                          if (value.trim() == ref.read(userData)["email"]) {
                            return "Please do not enter your email.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterSearch = value!.trim();
                        },
                      ),
                    ),
                  ),
                  if (!_isSearching)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            "Friend Request:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isSearching)
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              ),

                          // nếu nhưu đang search sẽ ko hiện
                          if (!_isSearching)
                            // nếu như đang xác nhận kết bạn thì nó sẽ loading ngăn user spam!
                            if (!_isLoading)
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(ref.read(userData)["uid"])
                                      .collection("friends")
                                      .where("status", isEqualTo: "request")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      final err = snapshot.error.toString();
                                      return Center(
                                        child: Text("ERR: $err"),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          "You have 0 request!",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      );
                                    }
                                    final friendRequestData =
                                        snapshot.data!.docs;
                                    return Column(
                                      children: [
                                        const SizedBox(height: 24),
                                        const Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Name",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Accept",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...friendRequestData
                                            .map((friendRequest) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                  onPressed: () {
                                                    final ortherUserData = {
                                                      "username": friendRequest
                                                          .data()["username"],
                                                      "email": friendRequest
                                                          .data()["email"],
                                                      "id": friendRequest.id
                                                    };
                                                    navigatorToOrtherUser(
                                                      context,
                                                      ortherUserData,
                                                      ref.read(userData)["uid"],
                                                    );
                                                  },
                                                  child: Text(
                                                    friendRequest
                                                        .data()["email"],
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                  ),
                                                  onPressed: () {
                                                    _acceptFriendRequest(
                                                      friendRequest.id,
                                                      friendRequest
                                                          .data()["username"],
                                                      friendRequest
                                                          .data()["email"],
                                                    );
                                                  },
                                                  child: const Text("Accept"),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  })
                        ],
                      ),
                    ),

                  // Kết quả tìm kiếm
                  if (_isSearching)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            "Result:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Name",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Email",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                          const SizedBox(height: 16),

                          // Stream tìm kiếm
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .where("email", isEqualTo: _enterSearch)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text("No result!"),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text("Error loading data!"),
                                );
                              }

                              final ortherUserData = {
                                "id": snapshot.data!.docs.first.id,
                                "username": snapshot.data!.docs.first
                                    .data()["username"],
                                "email":
                                    snapshot.data!.docs.first.data()["email"],
                              };

                              return TextButton(
                                onPressed: () {
                                  navigatorToOrtherUser(context, ortherUserData,
                                      ref.read(userData)["uid"]);
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              Text(ortherUserData["username"]),
                                        ),
                                        Expanded(
                                          child: Text(ortherUserData["email"]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 0.2,
                                      width: double.infinity,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    // Reset lại _isSearching khi đóng modal
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(ref.read(userData)["uid"])
          .collection("friends")
          .where("status", whereIn: ["friend", "request"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Loading...."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Friend list"),
            ),
            body: Center(
              child: Text(
                snapshot.error.toString(),
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        // ý tưởng để có chấm đỏ ở nút thêm bạn bè;
        // ta sẽ lấy cả 2 dữ liệu nếu như nó là req và đã là bạn
        // và sau đó lọc thành 2 list riêng biệt
        // nếu như có phần tử trong req thì nó sẽ hiện chấm đỏ
        final friendData = [];
        final friendRequest = [];
        for (final data in snapshot.data!.docs) {
          if (data.data()["status"] == "friend") {
            friendData.add(data);
            continue;
          }
          friendRequest.add(data);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Friend list"),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: _showModalBottomSearch,
                    icon: const Icon(Icons.person_add_alt_rounded),
                  ),
                  if (friendRequest.isNotEmpty)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Friend list",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                if (friendData.isEmpty)
                  const Text(
                    "You have 0 friends",
                    style: TextStyle(fontSize: 18),
                  ),
                if (friendData.isNotEmpty)
                  Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Text("Name"),
                          ),
                          Expanded(
                            child: Text("Email"),
                          ),
                        ],
                      ),
                      ...friendData.map(
                        (friend) => TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            final otherUserData = {
                              "username": friend.data()["username"],
                              "email": friend.data()["email"],
                              "id": friend.id,
                            };
                            navigatorToOrtherUser(context, otherUserData,
                                ref.read(userData)["uid"]);
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  friend.data()["username"] ?? "Loading...",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  friend.data()["email"] ?? "Loading...",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
