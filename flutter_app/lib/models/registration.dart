class Registration {
  final int id;
  final int userId;
  final int eventId;
  final DateTime registeredAt;
  final String status;
  final String? eventTitle;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final String? eventStatus;

  Registration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    required this.status,
    this.eventTitle,
    this.eventStartDate,
    this.eventEndDate,
    this.eventStatus,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      registeredAt: DateTime.parse(json['registeredAt']),
      status: json['status'],
      eventTitle: json['eventTitle'],
      eventStartDate: json['eventStartDate'] != null
          ? DateTime.parse(json['eventStartDate'])
          : null,
      eventEndDate: json['eventEndDate'] != null
          ? DateTime.parse(json['eventEndDate'])
          : null,
      eventStatus: json['eventStatus'],
    );
  }
}
