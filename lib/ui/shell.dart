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
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          _NavItem(Icons.today_outlined, Icons.today, tr(l, 'tabToday')),
          _NavItem(Icons.edit_calendar_outlined, Icons.edit_calendar,
              tr(l, 'tabPlan')),
          _NavItem(Icons.insights_outlined, Icons.insights, tr(l, 'tabStats')),
          _NavItem(Icons.settings_outlined, Icons.settings,
              tr(l, 'tabSettings')),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}

/// Simple custom bottom bar (does not depend on Material localizations).
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;
  const _BottomBar({
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 32,
                          decoration: BoxDecoration(
                            color: i == index
                                ? cs.secondaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            i == index ? items[i].selectedIcon : items[i].icon,
                            color: i == index
                                ? cs.onSecondaryContainer
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                i == index ? FontWeight.w700 : FontWeight.w400,
                            color: i == index
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
