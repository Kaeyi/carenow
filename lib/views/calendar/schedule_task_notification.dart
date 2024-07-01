import 'package:care_now/services/notifi_service.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

DateTime scheduleTime = DateTime.now();

class ScheduleTasksNotification extends StatefulWidget {
  const ScheduleTasksNotification({super.key, required this.title});

  final String title;

  @override
  State<ScheduleTasksNotification> createState() =>
      _ScheduleTasksNotificationState();
}

class _ScheduleTasksNotificationState extends State<ScheduleTasksNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DatePickerTxt(),
            ScheduleBtn(),
          ],
        )));
  }
}

class DatePickerTxt extends StatefulWidget {
  final void Function(DateTime)? onDateTimeSelected;
  const DatePickerTxt({super.key, this.onDateTimeSelected});

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  DateTime? scheduleTime; // Declare a variable to store the selected date/time

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        picker.DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => setState(() => scheduleTime = date),
          onConfirm: (date) {
            setState(() => scheduleTime = date);
            if (widget.onDateTimeSelected != null) {
              widget.onDateTimeSelected!(scheduleTime!);
            }
          },
        );
      },
      child: Text(
        scheduleTime != null
            ? // Check if a date/time is selected
            scheduleTime.toString()
            : // Display formatted date/time if selected
            'Select Date Time',
        style: const TextStyle(color: Colors.purple),
      ),
    );
  }
}

class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          debugPrint('NotificationScheduled for $scheduleTime');
          NotificationService().scheduleNotification(
              title: 'Scheduled Notification',
              body: '$scheduleTime',
              scheduledNotificationDateTime: scheduleTime);
        },
        child: const Text('Schedule Notifications'));
  }
}
