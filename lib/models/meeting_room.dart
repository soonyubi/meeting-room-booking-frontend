class MeetingRoom {
  final int id;
  final String name;
  final int capacity;
  final String description;
  final bool isActive;

  MeetingRoom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.description,
    required this.isActive,
  });

  factory MeetingRoom.fromJson(Map<String, dynamic> json) {
    return MeetingRoom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'description': description,
      'isActive': isActive,
    };
  }
}
