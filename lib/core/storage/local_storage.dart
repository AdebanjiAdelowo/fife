import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/body_measurement.dart';
import '../../models/journal_entry.dart';
import '../../models/schedule_task.dart';
import '../../models/user_profile.dart';
import '../../models/workout_report.dart';

/// Thin SharedPreferences-backed key/value persistence.
///
/// All collections are stored as JSON strings keyed by user id, so multiple
/// FiFers could share the device cleanly if we add account switching later.
class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  static LocalStorage? _instance;
  static LocalStorage get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError(
          'LocalStorage.init() must be awaited before use.');
    }
    return inst;
  }

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return _instance = LocalStorage._(prefs);
  }

  // --- Auth / users ---------------------------------------------------

  static const _kUsersIndex = 'users.index';
  static const _kCurrentUser = 'auth.currentUserId';

  Future<List<UserProfile>> allUsers() async {
    final ids = _prefs.getStringList(_kUsersIndex) ?? const [];
    return ids
        .map((id) => _prefs.getString(_userKey(id)))
        .whereType<String>()
        .map(UserProfile.decode)
        .toList();
  }

  Future<UserProfile?> findUserByEmail(String email) async {
    final users = await allUsers();
    for (final u in users) {
      if (u.email.toLowerCase() == email.toLowerCase()) return u;
    }
    return null;
  }

  Future<void> saveUser(UserProfile user) async {
    await _prefs.setString(_userKey(user.id), user.encode());
    final ids = _prefs.getStringList(_kUsersIndex) ?? const [];
    if (!ids.contains(user.id)) {
      await _prefs.setStringList(_kUsersIndex, [...ids, user.id]);
    }
  }

  Future<void> setCurrentUser(String userId) =>
      _prefs.setString(_kCurrentUser, userId);

  Future<void> clearCurrentUser() => _prefs.remove(_kCurrentUser);

  Future<UserProfile?> currentUser() async {
    final id = _prefs.getString(_kCurrentUser);
    if (id == null) return null;
    final raw = _prefs.getString(_userKey(id));
    if (raw == null) return null;
    return UserProfile.decode(raw);
  }

  String _userKey(String id) => 'user.$id';

  // --- Body measurements ---------------------------------------------

  Future<List<BodyMeasurement>> measurements(String userId) async {
    final raw = _prefs.getString('measurements.$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BodyMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMeasurement(
    String userId,
    BodyMeasurement measurement,
  ) async {
    final all = await measurements(userId);
    all.add(measurement);
    final raw = jsonEncode(all.map((m) => m.toJson()).toList());
    await _prefs.setString('measurements.$userId', raw);
  }

  // --- Journal entries -----------------------------------------------

  Future<List<JournalEntry>> journal(String userId) async {
    final raw = _prefs.getString('journal.$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveJournalEntry(String userId, JournalEntry entry) async {
    final all = await journal(userId);
    all.add(entry);
    await _prefs.setString(
      'journal.$userId',
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  // --- Schedule tasks (per day) --------------------------------------

  Future<List<ScheduleTask>> tasksForDate(String userId, String dateKey) async {
    final raw = _prefs.getString('schedule.$userId.$dateKey');
    if (raw == null) {
      final tasks = ScheduleTask.defaultDay(dateKey);
      await saveTasksForDate(userId, dateKey, tasks);
      return tasks;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ScheduleTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasksForDate(
    String userId,
    String dateKey,
    List<ScheduleTask> tasks,
  ) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString('schedule.$userId.$dateKey', raw);
    final history = _prefs.getStringList('schedule.$userId.history') ?? [];
    if (!history.contains(dateKey)) {
      history.add(dateKey);
      // Keep only the most recent 30 days in the index.
      history.sort();
      while (history.length > 30) {
        final oldest = history.removeAt(0);
        await _prefs.remove('schedule.$userId.$oldest');
      }
      await _prefs.setStringList('schedule.$userId.history', history);
    }
  }

  Future<List<DateTime>> scheduleHistoryDates(String userId) async {
    final history =
        _prefs.getStringList('schedule.$userId.history') ?? const [];
    return history
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  // --- Workout reports -----------------------------------------------

  Future<List<WorkoutReport>> workoutReports(String userId) async {
    final raw = _prefs.getString('workouts.$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WorkoutReport.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<void> saveWorkoutReport(
      String userId, WorkoutReport report) async {
    final all = await workoutReports(userId);
    all.add(report);
    await _prefs.setString(
      'workouts.$userId',
      jsonEncode(all.map((r) => r.toJson()).toList()),
    );
  }

  // --- Diet gallery --------------------------------------------------

  Future<List<DietGalleryEntry>> dietGallery(String userId) async {
    final raw = _prefs.getString('diet.$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DietGalleryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<void> saveDietGalleryEntry(
      String userId, DietGalleryEntry entry) async {
    final all = await dietGallery(userId);
    all.add(entry);
    await _prefs.setString(
      'diet.$userId',
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }
}
