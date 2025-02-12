import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(width: 18),
                Text(
                  'Task Manager',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                ),
              ],
            ),
          ),

          // chuyển hướng đến profile
          ListTile(
            leading: const Icon(Icons.person),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hello!"),
                Text(widget.userData["username"] ?? "No Data"),
              ],
            ),
            onTap: () {
              navigatorToProfile(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Chat"),
            onTap: () {
              navigatorToChat(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Friend list"),
            onTap: () {
              navigatorToListFriend(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Setting"),
            onTap: () {
              navigatorToSetting(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log out"),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
