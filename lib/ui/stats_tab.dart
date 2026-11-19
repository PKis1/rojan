import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import 'common.dart';

class StatsTab extends StatefulWidget {
  final AppState s;
  const StatsTab({super.key, required this.s});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;

  void _shift(int delta) {
    final d = DateTime(_year, _month + delta, 1);
    setState(() {
      _year = d.year;
      _month = d.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final l = s.lang;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final stats = s.statsFor(_year, _month);
    final rates = s.last7Rates();
    final now = DateTime.now();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr(l, 'statsTitle'),
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left)),
              Text('${monthNames(l)[_month - 1]} $_year',
                  style: tt.titleLarge),
              IconButton(
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right)),
            ],
          ),
          MonthReport(
              lang: l,
              stats: stats,
              label: '${monthNames(l)[_month - 1]} $_year'),
          SectionTitle(tr(l, 'last7')),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 110.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < 7; i++)
                      _Bar(
                        value: rates[i],
                        label: DateTime(now.year, now.month, now.day - (6 - i))
                            .day
                            .toString(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double? value;
  final String label;
  const _Bar({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = 70 * (value ?? 0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: value == null ? 4.0 : (h < 4.0 ? 4.0 : h),
          decoration: BoxDecoration(
            color: value == null ? cs.outlineVariant : cs.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// The monthly evaluation card. Also used inside the "new month" dialog.
class MonthReport extends StatelessWidget {
  final String lang;
  final MonthStats stats;
  final String label;
  const MonthReport({
    super.key,
    required this.lang,
    required this.stats,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (stats.total == 0) {
      return Card(
        color: cs.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(tr(lang, 'noData')),
        ),
      );
    }

    final pct = (stats.rate * 100).round();
    final evalKey = stats.rate >= 0.8
        ? 'evalGreat'
        : stats.rate >= 0.5
            ? 'evalGood'
            : 'evalLow';

    Widget tile(IconData icon, String title, String value) => Expanded(
          child: Column(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: 4.0),
              Text(value,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(title,
                  textAlign: TextAlign.center, style: tt.labelSmall),
            ],
          ),
        );

    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: stats.rate,
                      strokeWidth: 10,
                      backgroundColor: cs.outlineVariant,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$pct%',
                          style: tt.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(tr(lang, 'rate'), style: tt.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                tile(Icons.list_alt, tr(lang, 'tasksTotal'), '${stats.total}'),
                tile(Icons.check_circle_outline, tr(lang, 'tasksDone'),
                    '${stats.done}'),
                tile(Icons.star_outline, tr(lang, 'bestDay'),
                    stats.bestDay?.toString() ?? '-'),
                tile(Icons.local_fire_department_outlined,
                    tr(lang, 'streak'), '${stats.streak}'),
              ],
            ),
            const SizedBox(height: 20.0),
            Text(tr(lang, evalKey),
                textAlign: TextAlign.center,
                style: tt.bodyLarge?.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }
}
