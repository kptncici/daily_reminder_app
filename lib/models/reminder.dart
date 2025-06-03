import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Reminder {
  final String? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  // Untuk tampilan teks tanggal
  String get formattedDateTime {
    return DateFormat('EEEE, MMMM d, HH:mm').format(dateTime);
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Untuk SQLite & juga Firestore (selaras)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] is String
          ? DateTime.parse(map['dateTime'])
          : (map['dateTime'] as Timestamp)
                .toDate(), // Antisipasi Firestore/SQLite
      isCompleted: (map['isCompleted'] is bool)
          ? map['isCompleted']
          : (map['isCompleted'] ?? 0) == 1,
    );
  }

  // Untuk Firestore simpan
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
