import 'package:flutter/material.dart';
import 'package:task_manager_app/utils/navigation_helper.dart';
import 'package:task_manager_app/widget/add_task.dart';

class BottomNavigator extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavigator(
      {required this.currentIndex, required this.onTap, super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  void _addTask() async {
    final res = await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext builder) {
        return const AddTask();
      },
    );
    if (res == null) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      width: double.infinity,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Theme.of(context).colorScheme.primary,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.currentIndex == 0
                        ? () {}
                        : () {
                            navigatorToHomePage(context);
                          },
                    icon: Icon(
                      Icons.home,
                      color: widget.currentIndex == 0
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.currentIndex == 1
                        ? () {}
                        : () {
                            navigatorToAllTask(context);
                          },
                    icon: Icon(
                      Icons.list_alt,
                      color: widget.currentIndex == 1
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  IconButton(
                    onPressed: widget.currentIndex == 2
                        ? () {}
                        : () {
                            navigatorToNotification(context);
                          },
                    icon: Icon(
                      Icons.notifications,
                      color: widget.currentIndex == 2
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.currentIndex == 3
                        ? () {}
                        : () {
                            navigatorToProfile(context);
                          },
                    icon: Icon(
                      Icons.person,
                      color: widget.currentIndex == 3
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                    ),
                  ),
                ]),
          ),
          Positioned(
            bottom: 20,
            child: FloatingActionButton(
              elevation: 0.0,
              onPressed: _addTask,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
