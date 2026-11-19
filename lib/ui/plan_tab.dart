import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import 'common.dart';

/// Where the user plans tomorrow. This is the screen the nightly reminder
/// is meant to bring them to.
class PlanTab extends StatefulWidget {
  final AppState s;
  const PlanTab({super.key, required this.s});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  final TextEditingController _title = TextEditingController();
  TimeOfDay? _time;

  AppState get s => widget.s;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _add(DateTime tomorrow) {
    final text = _title.text.trim();
    if (text.isEmpty) return;
    s.addTask(
      text,
      dateKey(tomorrow),
      _time == null ? null : hm(_time!.hour, _time!.minute),
    );
    _title.clear();
    setState(() => _time = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = s.lang;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final list = s.tasksOn(dateKey(tomorrow));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr(l, 'planTitle'),
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${tomorrow.day} ${monthNames(l)[tomorrow.month - 1]} ${tomorrow.year}',
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(tr(l, 'planSub'),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(tomorrow),
                    decoration: InputDecoration(
                      hintText: tr(l, 'taskHint'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InputChip(
                        avatar: const Icon(Icons.schedule, size: 18),
                        label: Text(_time == null
                            ? tr(l, 'setTime')
                            : hm(_time!.hour, _time!.minute)),
                        onPressed: _pickTime,
                        onDeleted: _time == null
                            ? null
                            : () => setState(() => _time = null),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _add(tomorrow),
                        icon: const Icon(Icons.add),
                        label: Text(tr(l, 'add')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(tr(l, 'noTasksTomorrow'),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            )
          else
            for (final t in list)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: cs.surfaceContainerHighest,
                child: ListTile(
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: Text(t.title),
                  subtitle: t.time == null ? null : Text(t.time!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => s.remove(t.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
