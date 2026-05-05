class BodyMeasurement {
  BodyMeasurement({
    required this.id,
    required this.recordedAt,
    required this.bustInches,
    required this.waistUnderbustInches,
    required this.waistBellyButtonInches,
    required this.hipsInches,
    required this.weightKg,
    this.frontPhotoPath,
    this.leftPhotoPath,
    this.rightPhotoPath,
    this.backPhotoPath,
    this.upperBodyCurve = 0,
    this.lowerBodyCurve = 0,
    this.performance = 0,
  });

  final String id;
  final DateTime recordedAt;
  final double bustInches;
  final double waistUnderbustInches;
  final double waistBellyButtonInches;
  final double hipsInches;
  final double weightKg;

  String? frontPhotoPath;
  String? leftPhotoPath;
  String? rightPhotoPath;
  String? backPhotoPath;

  // Derived metrics (auto-computed but stored for performance display)
  double upperBodyCurve;
  double lowerBodyCurve;
  double performance; // 0..100

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'bustInches': bustInches,
        'waistUnderbustInches': waistUnderbustInches,
        'waistBellyButtonInches': waistBellyButtonInches,
        'hipsInches': hipsInches,
        'weightKg': weightKg,
        'frontPhotoPath': frontPhotoPath,
        'leftPhotoPath': leftPhotoPath,
        'rightPhotoPath': rightPhotoPath,
        'backPhotoPath': backPhotoPath,
        'upperBodyCurve': upperBodyCurve,
        'lowerBodyCurve': lowerBodyCurve,
        'performance': performance,
      };

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      BodyMeasurement(
        id: json['id'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        bustInches: (json['bustInches'] as num).toDouble(),
        waistUnderbustInches:
            (json['waistUnderbustInches'] as num).toDouble(),
        waistBellyButtonInches:
            (json['waistBellyButtonInches'] as num).toDouble(),
        hipsInches: (json['hipsInches'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        frontPhotoPath: json['frontPhotoPath'] as String?,
        leftPhotoPath: json['leftPhotoPath'] as String?,
        rightPhotoPath: json['rightPhotoPath'] as String?,
        backPhotoPath: json['backPhotoPath'] as String?,
        upperBodyCurve: (json['upperBodyCurve'] as num?)?.toDouble() ?? 0,
        lowerBodyCurve: (json['lowerBodyCurve'] as num?)?.toDouble() ?? 0,
        performance: (json['performance'] as num?)?.toDouble() ?? 0,
      );
}
