class Location {
  final int id;
  final String name;
  final String? address;
  final int? capacity;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.name,
    this.address,
    this.capacity,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      capacity: json['capacity'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
