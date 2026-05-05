class WorkoutReport {
  WorkoutReport({
    required this.id,
    required this.recordedAt,
    required this.name,
    required this.workoutType,
    required this.team,
    required this.setsDone,
    required this.grandTotalSets,
    required this.howWasWorkout,
    required this.difficultExercise,
    required this.enjoyedExercise,
    required this.painOrStrain,
    this.sweatfiePath,
    this.time,
  });

  final String id;
  final DateTime recordedAt;
  final String name;
  final String workoutType;
  final String team;
  final int setsDone;
  final int grandTotalSets;
  final String howWasWorkout;
  final String difficultExercise;
  final String enjoyedExercise;
  final String painOrStrain;
  String? sweatfiePath;
  String? time;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'name': name,
        'workoutType': workoutType,
        'team': team,
        'setsDone': setsDone,
        'grandTotalSets': grandTotalSets,
        'howWasWorkout': howWasWorkout,
        'difficultExercise': difficultExercise,
        'enjoyedExercise': enjoyedExercise,
        'painOrStrain': painOrStrain,
        'sweatfiePath': sweatfiePath,
        'time': time,
      };

  factory WorkoutReport.fromJson(Map<String, dynamic> json) => WorkoutReport(
        id: json['id'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        name: json['name'] as String,
        workoutType: json['workoutType'] as String,
        team: json['team'] as String,
        setsDone: json['setsDone'] as int,
        grandTotalSets: json['grandTotalSets'] as int,
        howWasWorkout: json['howWasWorkout'] as String,
        difficultExercise: json['difficultExercise'] as String,
        enjoyedExercise: json['enjoyedExercise'] as String,
        painOrStrain: json['painOrStrain'] as String,
        sweatfiePath: json['sweatfiePath'] as String?,
        time: json['time'] as String?,
      );
}

class DietGalleryEntry {
  DietGalleryEntry({
    required this.id,
    required this.recordedAt,
    required this.imagePath,
    this.note,
  });

  final String id;
  final DateTime recordedAt;
  final String imagePath;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'imagePath': imagePath,
        'note': note,
      };

  factory DietGalleryEntry.fromJson(Map<String, dynamic> json) =>
      DietGalleryEntry(
        id: json['id'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        imagePath: json['imagePath'] as String,
        note: json['note'] as String?,
      );
}
