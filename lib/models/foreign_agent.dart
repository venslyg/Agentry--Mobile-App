class ForeignAgent {
  final String id;
  final String name;
  final String country;
  final String notes;

  ForeignAgent({
    required this.id,
    required this.name,
    required this.country,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'notes': notes,
    };
  }

  factory ForeignAgent.fromMap(Map<String, dynamic> map) {
    return ForeignAgent(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      country: map['country'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
