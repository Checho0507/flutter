class Schedule {
  final int id;
  final int eventId;
  final String title;
  final String? speaker;
  final DateTime startTime;
  final DateTime endTime;
  final String? room;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.eventId,
    required this.title,
    this.speaker,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.createdAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      eventId: json['eventId'],
      title: json['title'],
      speaker: json['speaker'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      room: json['room'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'speaker': speaker,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'room': room,
      };
}
