import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import 'common.dart';

class TodayTab extends StatelessWidget {
  final AppState s;
  const TodayTab({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final l = s.lang;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final list = s.tasksOn(dateKey(now));
    final done = list.where((t) => t.done).length;
    final progress = list.isEmpty ? 0.0 : done / list.length;
    final greeting = s.name.isEmpty
        ? tr(l, 'helloNoName')
        : tr(l, 'hello', {'n': s.name});

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(greeting,
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${now.day} ${monthNames(l)[now.month - 1]} ${now.year}',
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Progress
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr(l, 'progress'),
                          style: tt.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w700)),
                      Text('$done / ${list.length}',
                          style: tt.titleMedium
                              ?.copyWith(color: cs.onPrimaryContainer)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quote
          Card(
            color: cs.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.format_quote_rounded,
                        color: cs.onTertiaryContainer),
                    const SizedBox(width: 8),
                    Text(tr(l, 'quoteTitle'),
                        style: tt.titleSmall?.copyWith(
                            color: cs.onTertiaryContainer,
                            fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Text(s.quote(),
                      style: tt.bodyLarge?.copyWith(
                          color: cs.onTertiaryContainer, height: 1.6)),
                ],
              ),
            ),
          ),

          SectionTitle(tr(l, 'todayTasks')),
          if (list.isEmpty)
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(tr(l, 'noTasksToday')),
              ),
            )
          else
            for (final t in list)
              Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                ),
                onDismissed: (_) => s.remove(t.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: cs.surfaceContainerHighest,
                  child: CheckboxListTile(
                    value: t.done,
                    onChanged: (_) => s.toggle(t.id),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.done ? TextDecoration.lineThrough : null,
                        color: t.done ? cs.onSurfaceVariant : null,
                      ),
                    ),
                    subtitle: t.time == null
                        ? null
                        : Row(children: [
                            const Icon(Icons.schedule, size: 14),
                            const SizedBox(width: 4),
                            Text(t.time!),
                          ]),
                  ),
                ),
              ),

          // Free-time ideas
          SectionTitle(tr(l, 'freeTitle')),
          Card(
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.lightbulb_outline,
                        color: cs.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s.idea(),
                          style: tt.bodyLarge?.copyWith(
                              color: cs.onSecondaryContainer, height: 1.5)),
                    ),
                  ]),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: s.nextIdea,
                      icon: const Icon(Icons.refresh),
                      label: Text(tr(l, 'newIdea')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
