import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/screens/add_user.dart';
import 'package:task_manager_app/screens/all_card.dart';
import 'package:task_manager_app/screens/all_user.dart';
import 'package:task_manager_app/screens/chat/chat.dart';
import 'package:task_manager_app/screens/chat/detail_chat.dart';
import 'package:task_manager_app/screens/forgot_password.dart';
import 'package:task_manager_app/screens/list_friend.dart';
import 'package:task_manager_app/screens/profile_orther_user.dart';
import 'package:task_manager_app/screens/search_result.dart';
import 'package:task_manager_app/screens/setting.dart';
import 'package:task_manager_app/screens/tabs.dart';
import 'package:task_manager_app/screens/home.dart';
import 'package:task_manager_app/screens/all_table.dart';

// vị trí index các Tab
//all task index = 1
// profile index = 3

void navigatorToProfile(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const TabsScreen(
        currentIndexTab: 3,
      ),
    ),
  );
}

void navigatorToNotification(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const TabsScreen(
        currentIndexTab: 2,
      ),
    ),
  );
}

void navigatorToAllTask(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const TabsScreen(
        currentIndexTab: 1,
      ),
    ),
  );
}

void navigatorToAllTable(
    context, String idTask, String uidCurrentUser, String uidAdmin) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AllTableScreen(
        idTask: idTask,
        uidCurrentUser: uidCurrentUser,
        uidAdmin: uidAdmin,
      ),
    ),
  );
}

void navigatorToAllCard(
  context,
  String idTask,
  String idTable,
  String endDateTask,
  String idAdmin,
  String taskName,
  Map<String, dynamic> currentUserData,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AllCardScreen(
        idTask: idTask,
        idTable: idTable,
        endDateTask: endDateTask,
        idAdmin: idAdmin,
        currentUserData: currentUserData,
        taskName: taskName,
      ),
    ),
  );
}

void navigatorToListFriend(context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const ListFriend(),
    ),
  );
}

void navigatorToOrtherUser(
    context, Map<String, dynamic> ortherUserData, String uidCurrentUser) {
  if (ortherUserData["id"] == uidCurrentUser) {
    navigatorToProfile(context);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ProfileOrtherUser(
        ortherUserData: ortherUserData,
      ),
    ),
  );
}

void navigatorToAddUser(
  context,
  Map<String, dynamic> taskData,
  Map<String, dynamic> currentUserData,
  List<QueryDocumentSnapshot> allUserData,
  String uidAdmin,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddUserScreen(
        taskData: taskData,
        allUser: allUserData,
        currentUserData: currentUserData,
        uidAdmin: uidAdmin,
      ),
    ),
  );
}

void navigatorToAllUser(
  context,
  Map<String, dynamic> taskData,
  Map<String, dynamic> currentUserData,
  String uidAdmin,
  List<QueryDocumentSnapshot> allUserData,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AllUserScreen(
        taskData: taskData,
        currentUserData: currentUserData,
        uidAdmin: uidAdmin,
      ),
    ),
  );
}

void navigatorToChat(context, [String uid = ""]) {
  // Nếu như uid ko tồn tại có nghĩa là đang chuyển hướng đến all chat
  if (uid.isEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Chat(),
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailChat(
          uidOrtherUser: uid,
        ),
      ),
    );
  }
}

void navigatorToSetting(context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const SettingScreen()),
  );
}

void navigatorToForgotPassword(context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
  );
}

void navigatorToSearchResult(context, String searchElement) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SearchResultScreen(
        searchElement: searchElement,
      ),
    ),
  );
}

void navigatorToHomePage(context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
    (route) => false,
  );
}
