class City {
  final int id;
  final String name;
  final int? parentId; // İlçeler için parent il ID'si

  City({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
    };
  }
}