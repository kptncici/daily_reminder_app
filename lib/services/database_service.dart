import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';

class DatabaseService {
  final CollectionReference _remindersCollection = FirebaseFirestore.instance
      .collection('reminders');

  Future<List<Reminder>> getAllReminders() async {
    final snapshot = await _remindersCollection.get();
    return snapshot.docs
        .map(
          (doc) => Reminder.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }

  Future<String> insertReminder(Reminder reminder) async {
    final docRef = _remindersCollection.doc();
    final reminderWithId = reminder.copyWith(id: docRef.id);
    await docRef.set(reminderWithId.toMap());
    return docRef.id;
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (reminder.id == null) return;
    await _remindersCollection.doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _remindersCollection.doc(id).delete();
  }
}
