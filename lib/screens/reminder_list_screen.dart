// lib/screens/reminder_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_reminder_app/providers/reminder_provider.dart';
import 'package:daily_reminder_app/screens/add_edit_reminder_screen.dart';
import 'package:daily_reminder_app/screens/settings_screen.dart'; // <<< PASTIKAN IMPORT INI ADA DAN BENAR

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reminders'),
        actions: [
          PopupMenuButton<ReminderSortOption>(
            onSelected: (ReminderSortOption result) {
              Provider.of<ReminderProvider>(
                context,
                listen: false,
              ).setSortOption(result);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<ReminderSortOption>>[
                  const PopupMenuItem<ReminderSortOption>(
                    value: ReminderSortOption.byDate,
                    child: Text('Sort by Date'),
                  ),
                  const PopupMenuItem<ReminderSortOption>(
                    value: ReminderSortOption.byCompletion,
                    child: Text('Sort by Completion'),
                  ),
                ],
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const SettingsScreen(), // <<< PENGGUNAAN SettingsScreen
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.reminders.isEmpty) {
            return const Center(
              child: Text('No reminders yet! Add one below.'),
            );
          }
          return ListView.builder(
            itemCount: reminderProvider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminderProvider.reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: reminder.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    // --- PENGGUNAAN formattedDateTime ---
                    '${reminder.description}\n'
                    '${reminder.formattedDateTime}',
                    // --- AKHIR PENGGUNAAN formattedDateTime ---
                    style: TextStyle(
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: reminder.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          reminder.isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: reminder.isCompleted
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          reminderProvider.toggleReminderCompletion(
                            reminder.id!,
                            !reminder.isCompleted,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditReminderScreen(reminder: reminder),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                'Are you sure you want to delete this reminder?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    reminderProvider.deleteReminder(
                                      reminder.id!,
                                    );
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditReminderScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
