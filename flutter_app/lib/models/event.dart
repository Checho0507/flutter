class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final int? categoryId;
  final int? locationId;
  final int? organizerId;
  final int? maxAttendees;
  final String status;
  final DateTime createdAt;
  final String? categoryName;
  final String? locationName;
  final int registrationCount;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.locationId,
    this.organizerId,
    this.maxAttendees,
    required this.status,
    required this.createdAt,
    this.categoryName,
    this.locationName,
    this.registrationCount = 0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      categoryId: json['categoryId'],
      locationId: json['locationId'],
      organizerId: json['organizerId'],
      maxAttendees: json['maxAttendees'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      categoryName: json['categoryName'],
      locationName: json['locationName'],
      registrationCount: json['registrationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'categoryId': categoryId,
        'locationId': locationId,
        'organizerId': organizerId,
        'maxAttendees': maxAttendees,
        'status': status,
      };
}
