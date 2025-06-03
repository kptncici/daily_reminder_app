import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';

class StorageService {
  final CollectionReference _firebaseBackup = FirebaseFirestore.instance
      .collection('reminder_backup');

  Future<void> saveReminderToFirebase(Reminder reminder) async {
    if (reminder.id == null) return;
    await _firebaseBackup.doc(reminder.id).set(reminder.toMap());
  }

  Future<void> deleteReminderFromFirebase(String id) async {
    await _firebaseBackup.doc(id).delete();
  }

  Future<List<Reminder>> loadRemindersFromFirebase() async {
    final snapshot = await _firebaseBackup.get();
    return snapshot.docs
        .map(
          (doc) => Reminder.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }
}
