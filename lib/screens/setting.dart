import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/setting.dart';
import 'package:task_manager_app/widget/edit_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  void _showModalChangePassword() async {
    final res = await showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return const EditPassword();
        });
    if (res != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Row(
            //   children: [
            //     const Expanded(
            //       child: Text(
            //         "Dark Mode",
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //     Expanded(
            //       child: Switch(
            //         value: ref.watch(darkTheme.notifier).state,
            //         onChanged: (bool value) async {
            //           SharedPreferences prefs =
            //               await SharedPreferences.getInstance();
            //           await prefs.setBool(
            //             'isDarkMode',
            //             value,
            //           );
            //           setState(() {
            //             ref.read(darkTheme.notifier).state = value;
            //           });
            //         },
            //         activeColor: Theme.of(context).colorScheme.primary,
            //       ),
            //     )
            //   ],
            // ),
            TextButton(
              onPressed: _showModalChangePassword,
              child: const Text(
                "Change Password",
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
}
