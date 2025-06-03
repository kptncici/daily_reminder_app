import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

enum ReminderSortOption { byDate, byCompletion }

class ReminderProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

  List<Reminder> _reminders = [];
  ReminderSortOption _sortOption = ReminderSortOption.byDate;

  List<Reminder> get reminders => [..._reminders];
  ReminderSortOption get sortOption => _sortOption;

  ReminderProvider() {
    loadReminders();
  }

  Future<void> loadReminders() async {
    _reminders = await _databaseService.getAllReminders();

    // Jika Firestore kosong, coba ambil dari backup Firebase
    if (_reminders.isEmpty) {
      final firebaseReminders = await _storageService
          .loadRemindersFromFirebase();
      for (final reminder in firebaseReminders) {
        await _databaseService.insertReminder(reminder);
      }
      _reminders = await _databaseService.getAllReminders();
    }

    _sortReminders();
    notifyListeners();
  }

  void setSortOption(ReminderSortOption option) {
    _sortOption = option;
    _sortReminders();
    notifyListeners();
  }

  void _sortReminders() {
    if (_sortOption == ReminderSortOption.byDate) {
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } else {
      _reminders.sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return a.dateTime.compareTo(b.dateTime);
        }
        return a.isCompleted ? 1 : -1;
      });
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final id = await _databaseService.insertReminder(reminder);
    final newReminder = reminder.copyWith(id: id);
    _reminders.add(newReminder);

    await _notificationService.scheduleMultipleNotifications(newReminder);
    await _storageService.saveReminderToFirebase(newReminder);

    _sortReminders();
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _databaseService.updateReminder(reminder);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;

      await _notificationService.cancelNotifications(reminder.id!);
      await _notificationService.scheduleMultipleNotifications(reminder);
      await _storageService.saveReminderToFirebase(reminder);

      _sortReminders();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    await _databaseService.deleteReminder(id);
    _reminders.removeWhere((r) => r.id == id);

    await _notificationService.cancelNotifications(id);
    await _storageService.deleteReminderFromFirebase(id);

    notifyListeners();
  }

  Future<void> toggleReminderCompletion(String id, bool isCompleted) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updatedReminder = _reminders[index].copyWith(
        isCompleted: isCompleted,
      );

      await _databaseService.updateReminder(updatedReminder);
      await _storageService.saveReminderToFirebase(updatedReminder);

      _reminders[index] = updatedReminder;

      _sortReminders();
      notifyListeners();
    }
  }
}
