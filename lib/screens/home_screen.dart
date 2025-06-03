import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import 'form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.currentThemeColor == AppThemeColor.black
        ? Colors.black
        : themeProvider.currentTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminder'),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<AppThemeColor>(
            icon: const Icon(Icons.color_lens),
            onSelected: (color) {
              themeProvider.setThemeColor(color);
            },
            itemBuilder: (_) => AppThemeColor.values.map((color) {
              return PopupMenuItem<AppThemeColor>(
                value: color,
                child: Text(
                  '${color.name[0].toUpperCase()}${color.name.substring(1)} Theme',
                ),
              );
            }).toList(),
          ),
          Consumer<ReminderProvider>(
            builder: (context, provider, _) =>
                PopupMenuButton<ReminderSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: (option) {
                    provider.setSortOption(option);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: ReminderSortOption.byDate,
                      child: Text('Sort by Date'),
                    ),
                    PopupMenuItem(
                      value: ReminderSortOption.byCompletion,
                      child: Text('Sort by Completion'),
                    ),
                  ],
                ),
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, _) {
          final reminders = provider.reminders;

          if (reminders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengingat.\nKetuk tombol + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            itemCount: reminders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final dateFormatted = DateFormat.yMMMEd().add_jm().format(
                reminder.dateTime,
              );

              return ListTile(
                leading: Icon(
                  reminder.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: reminder.isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(reminder.title),
                subtitle: Text(dateFormatted),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Pengingat?'),
                        content: const Text(
                          'Apakah kamu yakin ingin menghapus pengingat ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteReminder(reminder.id!);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FormScreen(reminder: reminder),
                    ),
                  );
                },
                onLongPress: () {
                  provider.toggleReminderCompletion(
                    reminder.id!,
                    !reminder.isCompleted,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const FormScreen()));
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
