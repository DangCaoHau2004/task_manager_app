import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/screens/all_task.dart';
import 'package:task_manager_app/screens/notification.dart';
import 'package:task_manager_app/widget/bottom_navigate.dart';
import 'package:task_manager_app/screens/profile.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key, required this.currentIndexTab});
  final int currentIndexTab;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProFileScreenState();
  }
}

class _ProFileScreenState extends ConsumerState<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    Widget currentTab = const ProfileScreen();
    String currentTabTitle = "Profile"; // Khai báo ngoài if

    // Kiểm tra giá trị index tab
    if (widget.currentIndexTab == 1) {
      currentTab = const AllTaskScreen();
      currentTabTitle = "All Task"; // Cập nhật giá trị ở đây
    }
    if (widget.currentIndexTab == 2) {
      currentTab = const NotificationScreen();
      currentTabTitle = "Notification"; // Cập nhật giá trị ở đây
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTabTitle),
        centerTitle: true,
      ),
      body: currentTab,
      bottomNavigationBar: BottomNavigator(
        currentIndex: widget.currentIndexTab,
        onTap: (int index) {},
      ),
    );
  }
}
