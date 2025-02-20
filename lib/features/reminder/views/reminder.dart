import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:appointement/features/reminder/widgets/noti_service.dart';

/*
class Reminder {

  final NotiService notiService = NotiService();
  TimeOfDay? _selectedTime;


  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Function to schedule a notification
  void _scheduleNotification() {
    if (_selectedTime == null) return;

    // Create a DateTime object using the selected time and today's date
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Call the scheduleNotification method with the DateTime object
    notiService.scheduleNotification(
      title: 'Scheduled Notification',
      body: 'This is a scheduled notification!',
      reminderTime: scheduledDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification scheduled for ${_selectedTime!.format(context)}',
        ),
      ),
    );
  }
}

 */