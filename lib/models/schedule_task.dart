enum TaskStatus { pending, done, failed }

class ScheduleTask {
  ScheduleTask({
    required this.id,
    required this.label,
    required this.description,
    required this.deadline,
    this.status = TaskStatus.pending,
    this.dateKey,
  });

  final String id;
  final String label;       // e.g. "Get Up, Get Sweating"
  final String description; // e.g. "Morning Workout"
  final String deadline;    // e.g. "7:00 AM"
  TaskStatus status;
  String? dateKey; // yyyy-MM-dd; used so the daily list can refresh every 24h

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'description': description,
        'deadline': deadline,
        'status': status.name,
        'dateKey': dateKey,
      };

  factory ScheduleTask.fromJson(Map<String, dynamic> json) => ScheduleTask(
        id: json['id'] as String,
        label: json['label'] as String,
        description: json['description'] as String,
        deadline: json['deadline'] as String,
        status: TaskStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TaskStatus.pending,
        ),
        dateKey: json['dateKey'] as String?,
      );

  static List<ScheduleTask> defaultDay(String dateKey) => [
        ScheduleTask(
          id: '$dateKey-morning',
          label: 'Get Up, Get Sweating',
          description: 'Morning Workout',
          deadline: '6:30 AM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-water-1',
          label: 'Stay Hydrated',
          description: 'Water and Breath Break 1',
          deadline: '9:00 AM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-water-2',
          label: 'Stay Hydrated',
          description: 'Water and Breath Break 2',
          deadline: '1:00 PM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-water-3',
          label: 'Stay Hydrated',
          description: 'Water and Breath Break 3',
          deadline: '4:00 PM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-evening',
          label: 'Stretch it Out',
          description: 'Evening Workout',
          deadline: '6:00 PM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-checkin-1',
          label: 'Report to Community',
          description: 'FIFER Check In 1',
          deadline: '8:00 PM',
          dateKey: dateKey,
        ),
        ScheduleTask(
          id: '$dateKey-checkin-2',
          label: 'Report to Community',
          description: 'FIFER Check In 2',
          deadline: '10:00 PM',
          dateKey: dateKey,
        ),
      ];
}
