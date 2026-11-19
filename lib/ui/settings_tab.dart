import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../notifications.dart';
import 'common.dart';
import 'onboarding.dart';

class SettingsTab extends StatelessWidget {
  final AppState s;
  const SettingsTab({super.key, required this.s});

  Future<void> _pick(BuildContext context, int h, int m,
      void Function(int, int) onPicked) async {
    final r = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: h, minute: m));
    if (r != null) onPicked(r.hour, r.minute);
  }

  Future<void> _editName(BuildContext context) async {
    final l = s.lang;
    final c = TextEditingController(text: s.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(l, 'changeName')),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr(l, 'close'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Icon(Icons.check)),
        ],
      ),
    );
    if (ok == true) s.setName(c.text.trim());
  }

  Future<void> _toggleNotifications(BuildContext context, bool v) async {
    final messenger = ScaffoldMessenger.of(context);
    if (v) {
      final granted = await Notifier.instance.requestPermission();
      if (!granted) {
        messenger
            .showSnackBar(SnackBar(content: Text(tr(s.lang, 'permDenied'))));
        return;
      }
    }
    await s.setNotifications(v);
  }

  @override
  Widget build(BuildContext context) {
    final l = s.lang;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr(l, 'settingsTitle'),
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),

          SectionTitle(tr(l, 'language')),
          SegmentedButton<String>(
            segments: [
              for (final code in supportedLangs)
                ButtonSegment(value: code, label: Text(langNames[code]!)),
            ],
            selected: {s.lang},
            onSelectionChanged: (v) => s.setLang(v.first),
          ),

          Card(
            margin: const EdgeInsets.only(top: 16),
            color: cs.surfaceContainerHighest,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(tr(l, 'changeName')),
              subtitle: Text(s.name.isEmpty ? '-' : s.name),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editName(context),
            ),
          ),

          SectionTitle(tr(l, 'notifications')),
          Card(
            color: cs.surfaceContainerHighest,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(tr(l, 'notifications')),
                  value: s.notificationsOn,
                  onChanged: (v) => _toggleNotifications(context, v),
                ),
                const Divider(height: 1),
                ListTile(
                  enabled: s.notificationsOn,
                  leading: const Icon(Icons.nightlight_outlined),
                  title: Text(tr(l, 'nightReminder')),
                  trailing: Text(hm(s.nightH, s.nightM), style: tt.titleMedium),
                  onTap: () => _pick(context, s.nightH, s.nightM, s.setNight),
                ),
                const Divider(height: 1),
                ListTile(
                  enabled: s.notificationsOn,
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: Text(tr(l, 'morningReminder')),
                  trailing:
                      Text(hm(s.morningH, s.morningM), style: tt.titleMedium),
                  onTap: () =>
                      _pick(context, s.morningH, s.morningM, s.setMorning),
                ),
              ],
            ),
          ),

          Card(
            margin: const EdgeInsets.only(top: 16),
            color: cs.surfaceContainerHighest,
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(tr(l, 'replayTutorial')),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => OnboardingScreen(state: s, replay: true))),
            ),
          ),
        ],
      ),
    );
  }
}
