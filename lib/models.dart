import 'dart:convert';

/// A single to-do item that belongs to one calendar day.
class Task {
  final String id;
  String title;
  String date; // yyyy-MM-dd
  String? time; // HH:mm (optional, used for a reminder)
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'done': done,
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        date: j['date'] as String,
        time: j['time'] as String?,
        done: (j['done'] as bool?) ?? false,
      );

  static String encodeList(List<Task> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Task> decodeList(String raw) => (jsonDecode(raw) as List)
      .map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList();
}

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseKey(String k) {
  final p = k.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String monthKey(int year, int month) =>
    '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

/// Aggregated numbers for one month, used by the review screen.
class MonthStats {
  final int total;
  final int done;
  final int? bestDay; // day-of-month with most completed tasks
  final int streak;
  const MonthStats({
    required this.total,
    required this.done,
    required this.bestDay,
    required this.streak,
  });

  double get rate => total == 0 ? 0 : done / total;
}
