import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../notifications.dart';

/// First-run tutorial. Page 0 picks language + name, then 4 tutorial pages.
/// With [replay] = true it only shows the 4 tutorial pages and pops when done.
class OnboardingScreen extends StatefulWidget {
  final AppState state;
  final bool replay;
  const OnboardingScreen({super.key, required this.state, this.replay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  late final TextEditingController _name =
      TextEditingController(text: widget.state.name);
  int _page = 0;

  AppState get s => widget.state;
  int get _count => widget.replay ? 4 : 5;
  String t(String k) => tr(s.lang, k);

  @override
  void dispose() {
    _ctrl.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    s.setName(_name.text.trim());
    await Notifier.instance.requestPermission();
    await s.finishOnboarding();
  }

  void _go(int delta) => _ctrl.animateToPage(
        _page + delta,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

  Widget _info(IconData icon, String title, String body) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 32),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _setupPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.wb_twilight_rounded,
              size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(t('onb0t'),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(t('onb0b'), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Text(t('chooseLang'),
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final l in supportedLangs)
                ChoiceChip(
                  label: Text(langNames[l]!),
                  selected: s.lang == l,
                  onSelected: (_) => s.setLang(l),
                ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: t('nameLabel'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      if (!widget.replay) _setupPage(),
      _info(Icons.nightlight_round, t('onb1t'), t('onb1b')),
      _info(Icons.notifications_active_rounded, t('onb2t'), t('onb2b')),
      _info(Icons.insights_rounded, t('onb3t'), t('onb3b')),
      _info(Icons.emoji_events_rounded, t('onb4t'), t('onb4b')),
    ];
    final last = _page == _count - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: last
                        ? null
                        : TextButton(
                            onPressed: () => _ctrl.animateToPage(_count - 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut),
                            child: Text(t('skip')),
                          ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _count; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: FilledButton(
                      onPressed: last ? _finish : () => _go(1),
                      child: Text(last ? t('start') : t('next')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
