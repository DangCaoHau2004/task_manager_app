import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/edit_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ProFileScreenState();
  }
}

class _ProFileScreenState extends ConsumerState<ProfileScreen> {
  void _editProfile() async {
    final res = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return const EditProfile();
      },
      useSafeArea: true,
      isScrollControlled: true,
    );
    if (res != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.toString(),
          ),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: const AssetImage(
                    "assets/images/user.png",
                  ),
                  backgroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  ref.watch(userData)["username"] ?? "No Data",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(ref.watch(userData)["email"] ?? "No Data"),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.all(12),
                  width: 300,
                  child: GestureDetector(
                    onTap: _editProfile,
                    child: Center(
                      child: Text(
                        "Edit profile",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      navigatorToListFriend(context);
                    },
                    icon: const Row(
                      children: [
                        Icon(
                          Icons.people,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Friend list",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.2,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Row(
                      children: [
                        Icon(
                          Icons.star,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.2,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  IconButton(
                    onPressed: () {
                      navigatorToSetting(context);
                    },
                    icon: const Row(
                      children: [
                        Icon(
                          Icons.settings,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Setting",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.2,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  IconButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      Navigator.of(context).popUntil((route) => route.isFirst);

                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Log Out",
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
