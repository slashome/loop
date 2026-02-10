enum TaskScheduleType { time, window, allDay }

class TaskSchedule {
  final TaskScheduleType type;
  final String? time;
  final String? start;
  final String? end;

  const TaskSchedule._(
    this.type, {
    this.time,
    this.start,
    this.end,
  });

  const TaskSchedule.time(String time)
      : this._(TaskScheduleType.time, time: time);

  const TaskSchedule.window(String start, String end)
      : this._(TaskScheduleType.window, start: start, end: end);

  const TaskSchedule.allDay() : this._(TaskScheduleType.allDay);

  String displayLabel() {
    switch (type) {
      case TaskScheduleType.time:
        if (time != null) {
          return 'Time • $time';
        }
        return 'Time';
      case TaskScheduleType.window:
        if (start != null && end != null) {
          return 'Window • $start-$end';
        }
        return 'Window';
      case TaskScheduleType.allDay:
        return 'All day';
    }
  }
}
