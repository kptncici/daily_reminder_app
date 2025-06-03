// lib/screens/add_edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_reminder_app/models/reminder.dart';
import 'package:daily_reminder_app/providers/reminder_provider.dart';
import 'package:intl/intl.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder; // Bisa null jika menambah baru

  const AddEditReminderScreen({super.key, this.reminder});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _selectedDateTime;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      // Mode edit
      _title = widget.reminder!.title;
      _description = widget.reminder!.description;
      _selectedDateTime = widget.reminder!.dateTime;
      _isCompleted = widget.reminder!.isCompleted;
    } else {
      // Mode tambah baru
      _title = '';
      _description = '';
      _selectedDateTime = DateTime.now().add(
        const Duration(hours: 1),
      ); // Default 1 jam dari sekarang
      _isCompleted = false;
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveReminder() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final reminderProvider = Provider.of<ReminderProvider>(
        context,
        listen: false,
      );

      if (widget.reminder != null) {
        // Update reminder yang sudah ada
        final updatedReminder = Reminder(
          id: widget.reminder!.id,
          title: _title,
          description: _description,
          dateTime: _selectedDateTime,
          isCompleted: _isCompleted,
        );
        reminderProvider.updateReminder(updatedReminder);
      } else {
        // Tambah reminder baru
        final newReminder = Reminder(
          title: _title,
          description: _description,
          dateTime: _selectedDateTime,
          isCompleted: _isCompleted,
        );
        reminderProvider.addReminder(newReminder);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminder == null ? 'Add New Reminder' : 'Edit Reminder',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date & Time: ${DateFormat('EEE, MMM d, yyyy HH:mm').format(_selectedDateTime)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDateTime,
                  ),
                ],
              ),
              if (widget.reminder !=
                  null) // Hanya tampilkan jika sedang mengedit
                CheckboxListTile(
                  title: const Text('Mark as Completed'),
                  value: _isCompleted,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isCompleted = newValue ?? false;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReminder,
                child: Text(
                  widget.reminder == null ? 'Add Reminder' : 'Update Reminder',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
