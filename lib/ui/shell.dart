import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import 'plan_tab.dart';
import 'settings_tab.dart';
import 'stats_tab.dart';
import 'today_tab.dart';

/// Main screen with the bottom navigation bar.
class Shell extends StatefulWidget {
  final AppState state;
  const Shell({super.key, required this.state});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowReview());
  }

  /// On the first open of a new month, show last month's report once.
  void _maybeShowReview() {
    if (!mounted) return;
    final now = DateTime.now();
    final current = monthKey(now.year, now.month);
    if (s.lastReviewMonth == current) return;
    final prev = DateTime(now.year, now.month - 1, 1);
    final stats = s.statsFor(prev.year, prev.month);
    s.markReviewShown(current);
    if (stats.total == 0) return;
    final l = s.lang;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(l, 'reviewTitle')),
        content: SingleChildScrollView(
          child: MonthReport(
            lang: l,
            stats: stats,
            label: '${monthNames(l)[prev.month - 1]} ${prev.year}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr(l, 'close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = s.lang;
    final tabs = <Widget>[
      TodayTab(s: s),
      PlanTab(s: s),
      StatsTab(s: s),
      SettingsTab(s: s),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today),
              label: tr(l, 'tabToday')),
          NavigationDestination(
              icon: const Icon(Icons.edit_calendar_outlined),
              selectedIcon: const Icon(Icons.edit_calendar),
              label: tr(l, 'tabPlan')),
          NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights),
              label: tr(l, 'tabStats')),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: tr(l, 'tabSettings')),
        ],
      ),
    );
  }
}
