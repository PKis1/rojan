import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'models.dart';
import 'notifications.dart';

/// Single source of truth for the whole app. Everything is stored locally on
/// the phone (SharedPreferences) - no account and no internet are needed.
class AppState extends ChangeNotifier {
  late SharedPreferences _p;

  List<Task> tasks = [];
  String lang = 'ku';
  String name = '';
  bool onboarded = false;
  bool notificationsOn = true;
  int nightH = 21, nightM = 30; // "plan tomorrow" reminder
  int morningH = 8, morningM = 0; // "today's tasks" reminder
  String lastReviewMonth = '';
  int ideaIndex = 0;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p.getString('tasks');
    if (raw != null) {
      try {
        tasks = Task.decodeList(raw);
      } catch (_) {
        tasks = [];
      }
    }
    lang = _p.getString('lang') ?? 'ku';
    name = _p.getString('name') ?? '';
    onboarded = _p.getBool('onboarded') ?? false;
    notificationsOn = _p.getBool('notif') ?? true;
    nightH = _p.getInt('nightH') ?? 21;
    nightM = _p.getInt('nightM') ?? 30;
    morningH = _p.getInt('morningH') ?? 8;
    morningM = _p.getInt('morningM') ?? 0;
    lastReviewMonth = _p.getString('lastReview') ?? '';
    ideaIndex = DateTime.now().day;
    if (onboarded) {
      await Notifier.instance.reschedule(this);
    }
  }

  // ---------------------------------------------------------------- tasks

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void addTask(String title, String date, String? time) {
    tasks.add(Task(id: _newId(), title: title, date: date, time: time));
    _saveTasks();
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  void toggle(String id) {
    final t = tasks.firstWhere((e) => e.id == id);
    t.done = !t.done;
    _saveTasks();
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  void remove(String id) {
    tasks.removeWhere((e) => e.id == id);
    _saveTasks();
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  void _saveTasks() => unawaited(_p.setString('tasks', Task.encodeList(tasks)));

  List<Task> tasksOn(String key) {
    final l = tasks.where((t) => t.date == key).toList();
    l.sort((a, b) => (a.time ?? '99:99').compareTo(b.time ?? '99:99'));
    return l;
  }

  // ------------------------------------------------------------- settings

  void setLang(String v) {
    lang = v;
    unawaited(_p.setString('lang', v));
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  void setName(String v) {
    name = v;
    unawaited(_p.setString('name', v));
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    notificationsOn = v;
    await _p.setBool('notif', v);
    notifyListeners();
    await Notifier.instance.reschedule(this);
  }

  void setNight(int h, int m) {
    nightH = h;
    nightM = m;
    unawaited(_p.setInt('nightH', h));
    unawaited(_p.setInt('nightM', m));
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  void setMorning(int h, int m) {
    morningH = h;
    morningM = m;
    unawaited(_p.setInt('morningH', h));
    unawaited(_p.setInt('morningM', m));
    notifyListeners();
    Notifier.instance.reschedule(this);
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await _p.setBool('onboarded', true);
    // The first month review should not pop up immediately.
    final now = DateTime.now();
    lastReviewMonth = monthKey(now.year, now.month);
    await _p.setString('lastReview', lastReviewMonth);
    await Notifier.instance.reschedule(this);
    notifyListeners();
  }

  void markReviewShown(String key) {
    lastReviewMonth = key;
    unawaited(_p.setString('lastReview', key));
  }

  // ---------------------------------------------------- quotes and ideas

  String quote() {
    final list = quotes[lang] ?? quotes['en']!;
    final now = DateTime.now();
    final day = now.difference(DateTime(now.year, 1, 1)).inDays;
    return list[day % list.length];
  }

  String idea() {
    final list = freeTimeIdeas[lang] ?? freeTimeIdeas['en']!;
    return list[ideaIndex % list.length];
  }

  void nextIdea() {
    ideaIndex++;
    notifyListeners();
  }

  // ---------------------------------------------------------------- stats

  MonthStats statsFor(int year, int month) {
    final prefix = monthKey(year, month);
    final inMonth = tasks.where((t) => t.date.startsWith(prefix)).toList();
    final doneCount = inMonth.where((t) => t.done).length;

    final perDay = <int, int>{};
    for (final t in inMonth.where((t) => t.done)) {
      final day = parseKey(t.date).day;
      perDay[day] = (perDay[day] ?? 0) + 1;
    }
    int? best;
    var bestCount = 0;
    perDay.forEach((day, c) {
      if (c > bestCount) {
        bestCount = c;
        best = day;
      }
    });

    return MonthStats(
      total: inMonth.length,
      done: doneCount,
      bestDay: best,
      streak: currentStreak(),
    );
  }

  bool _dayComplete(DateTime d) {
    final l = tasksOn(dateKey(d));
    return l.isNotEmpty && l.every((t) => t.done);
  }

  /// Consecutive days (ending today or yesterday) where every task was done.
  int currentStreak() {
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day);
    if (!_dayComplete(d)) d = DateTime(d.year, d.month, d.day - 1);
    var count = 0;
    while (_dayComplete(d)) {
      count++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return count;
  }

  /// Completion ratio for each of the last 7 days (null = no tasks that day).
  List<double?> last7Rates() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day - (6 - i));
      final l = tasksOn(dateKey(d));
      if (l.isEmpty) return null;
      return l.where((t) => t.done).length / l.length;
    });
  }
}
