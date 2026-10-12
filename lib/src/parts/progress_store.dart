part of '../../app.dart';

// ============================================================
// LOCAL PROGRESS STORAGE
// ============================================================

class ProgressStore {
  static String completedKey(String id) => 'lesson_${id}_completed';
  static String bestKey(String id) => 'lesson_${id}_best';
  static String lastKey(String id) => 'lesson_${id}_last';

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    int completedCount = 0;
    int xp = 0;
    final byLesson = <String, Map<String, dynamic>>{};

    for (final lesson in lessons) {
      final completed = prefs.getBool(completedKey(lesson.id)) ?? false;
      final best = prefs.getInt(bestKey(lesson.id)) ?? 0;
      final last = prefs.getInt(lastKey(lesson.id)) ?? 0;
      if (completed) completedCount++;
      xp += best * 10;
      byLesson[lesson.id] = {
        'completed': completed,
        'best': best,
        'last': last,
      };
    }

    return {'completedCount': completedCount, 'xp': xp, 'lessons': byLesson};
  }

  static Future<void> saveResult(LessonResource lesson, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final oldBest = prefs.getInt(bestKey(lesson.id)) ?? 0;

    await prefs.setBool(completedKey(lesson.id), true);
    await prefs.setInt(bestKey(lesson.id), score > oldBest ? score : oldBest);
    await prefs.setInt(lastKey(lesson.id), score);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final lesson in lessons) {
      await prefs.remove(completedKey(lesson.id));
      await prefs.remove(bestKey(lesson.id));
      await prefs.remove(lastKey(lesson.id));
    }
  }
}
