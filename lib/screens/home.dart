import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/main_drawer.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/widget/bottom_navigate.dart';
import 'package:task_manager_app/widget/recent_task.dart';
import 'package:task_manager_app/widget/today_task.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var defaultPage = 0;
  var _enterSearch = "";

  void _searchElement() {
    FocusScope.of(context).unfocus();
  }

  final _formSearchKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      endDrawer: MainDrawer(userData: ref.watch(userData)),
      backgroundColor: Theme.of(context).colorScheme.onTertiary,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text("Task manager"),
            const Spacer(),

            // chat icon button
            IconButton(
              onPressed: () {
                navigatorToChat(context);
              },
              icon: const Icon(
                Icons.chat,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // thanh tìm kiếm
          Container(
            height: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formSearchKey,
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  hintText: "Search...",
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    onPressed: _searchElement,
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Bạn chưa nhập!";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enterSearch = value.toString();
                },
              ),
            ),
          ),

          // nội dung chính
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Theme.of(context).colorScheme.onTertiary,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.70,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  children: const [
                    //recent task
                    RecentTask(),
                    SizedBox(height: 40),
                    TodayTask(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar:
          BottomNavigator(currentIndex: 0, onTap: (int index) {}),
    );
  }
}
