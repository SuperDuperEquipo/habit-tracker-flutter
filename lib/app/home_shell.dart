
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/features/habits/habits_provider.dart';
import 'package:rachas/features/habits/habits_screen.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/statistics/statistics_screen.dart';

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
        children: [
          const HabitsScreen(),
          Consumer<HabitsProvider>(
            builder: (context, provider, _) {
              return StatisticsView(habits: provider.habits);
            },
          ),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: AppStrings.navHabits,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: AppStrings.navStats,
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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late final Future<String?> _nameFuture;

  @override
  void initState() {
    super.initState();
    _nameFuture = context.read<AuthService>().readDisplayName();
  }

  Future<void> _signOut() async {
    final authService = context.read<AuthService>();
    await authService.signOut();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<String?>(
              future: _nameFuture,
              builder: (context, snapshot) {
                final name = snapshot.data;

                if (name == null || name.isEmpty) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    AppStrings.profileGreeting(name),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              },
            ),
            const Text(AppStrings.featureUnavailable),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
