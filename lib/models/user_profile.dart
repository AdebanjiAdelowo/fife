import 'dart:convert';

class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.passwordHash,
    this.programCode,
    this.fullName,
    this.profilePhotoPath,
    this.age,
    this.heightCm,
    this.sex,
    this.weightKg,
    this.nationality,
    this.location,
    this.currentProgramName,
    this.currentProgramDuration,
    this.bodyGoal,
    this.profileCompletion = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String email;
  String passwordHash;
  String? programCode;
  String? fullName;
  String? profilePhotoPath;
  int? age;
  double? heightCm;
  String? sex;
  double? weightKg;
  String? nationality;
  String? location;
  String? currentProgramName;
  String? currentProgramDuration;
  String? bodyGoal;
  int profileCompletion; // 0..10
  final DateTime createdAt;

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm == 0) return null;
    final h = heightCm! / 100.0;
    return weightKg! / (h * h);
  }

  String? get bmiCategory {
    final value = bmi;
    if (value == null) return null;
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Healthy';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'passwordHash': passwordHash,
        'programCode': programCode,
        'fullName': fullName,
        'profilePhotoPath': profilePhotoPath,
        'age': age,
        'heightCm': heightCm,
        'sex': sex,
        'weightKg': weightKg,
        'nationality': nationality,
        'location': location,
        'currentProgramName': currentProgramName,
        'currentProgramDuration': currentProgramDuration,
        'bodyGoal': bodyGoal,
        'profileCompletion': profileCompletion,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        programCode: json['programCode'] as String?,
        fullName: json['fullName'] as String?,
        profilePhotoPath: json['profilePhotoPath'] as String?,
        age: json['age'] as int?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        sex: json['sex'] as String?,
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        nationality: json['nationality'] as String?,
        location: json['location'] as String?,
        currentProgramName: json['currentProgramName'] as String?,
        currentProgramDuration: json['currentProgramDuration'] as String?,
        bodyGoal: json['bodyGoal'] as String?,
        profileCompletion: (json['profileCompletion'] as int?) ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  String encode() => jsonEncode(toJson());
  static UserProfile decode(String raw) =>
      UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
