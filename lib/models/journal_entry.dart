enum JournalMood {
  happy,
  angry,
  sad,
  confused,
  hopeful,
  skeptical;

  String get label {
    switch (this) {
      case JournalMood.happy:
        return 'Happy';
      case JournalMood.angry:
        return 'Angry';
      case JournalMood.sad:
        return 'Sad';
      case JournalMood.confused:
        return 'Confused';
      case JournalMood.hopeful:
        return 'Hopeful';
      case JournalMood.skeptical:
        return 'Skeptical';
    }
  }

  String get emoji {
    switch (this) {
      case JournalMood.happy:
        return '😄';
      case JournalMood.angry:
        return '😡';
      case JournalMood.sad:
        return '😢';
      case JournalMood.confused:
        return '😕';
      case JournalMood.hopeful:
        return '🌱';
      case JournalMood.skeptical:
        return '🤨';
    }
  }
}

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
    this.isFirstEntry = false,
  });

  final String id;
  final String title;
  final String body;
  final JournalMood mood;
  final DateTime createdAt;
  final bool isFirstEntry;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood.name,
        'createdAt': createdAt.toIso8601String(),
        'isFirstEntry': isFirstEntry,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        mood: JournalMood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => JournalMood.hopeful,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isFirstEntry: json['isFirstEntry'] as bool? ?? false,
      );
}
