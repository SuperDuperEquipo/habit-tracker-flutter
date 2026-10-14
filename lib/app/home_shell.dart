import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/habits_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HabitsScreen(), _ProfileTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: AppStrings.navHabits,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navProfile)),
      body: const Center(child: Text(AppStrings.featureUnavailable)),
    );
  }
}
