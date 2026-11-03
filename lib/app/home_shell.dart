import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/widgets/app_logo.dart';
import 'package:rachas/features/habits/habits_provider.dart';
import 'package:rachas/features/habits/habits_screen.dart';
import 'package:rachas/features/login/auth_service.dart';
import 'package:rachas/features/notifications/notification_service.dart';
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
      // Línea fina arriba de la barra, como en Stitch.
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.skyBlue)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
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
    // Se guardan las dependencias antes del await para no usar el context.
    final navigator = Navigator.of(context);
    final auth = context.read<AuthService>();
    final notifications = context.read<NotificationService?>();
    await auth.signOut();
    // Los recordatorios son de la cuenta que sale.
    await notifications?.cancelAll();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                const AppLogo(size: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTheme.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.navProfile,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.beige,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.skyBlue),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppTheme.navy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String?>(
                    future: _nameFuture,
                    builder: (context, snapshot) {
                      final name = snapshot.data?.trim() ?? '';
                      return Text(
                        name.isEmpty
                            ? AppStrings.profileDefaultTitle
                            : AppStrings.profileGreeting(name),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.profileBody,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.slateBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.signOut),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppTheme.beige,
                foregroundColor: AppTheme.darkPink,
                side: const BorderSide(color: AppTheme.darkPink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
