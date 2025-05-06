class City {
  final String id;
  final String name;
  final String nameEn;
  final String? parentId; // Used for district's parent city ID

  City({
    required this.id,
    required this.name,
    this.nameEn = '',
    this.parentId,
  });

  // Factory constructor for city from API
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['SehirID'] ?? json['id'] ?? '',
      name: json['SehirAdi'] ?? json['name'] ?? '',
      nameEn: json['SehirAdiEn'] ?? json['nameEn'] ?? '',
      parentId: json['parentId'],
    );
  }

  // Factory constructor for district from API
  factory City.districtFromJson(Map<String, dynamic> json) {
    return City(
      id: json['IlceID'] ?? json['id'] ?? '',
      name: json['IlceAdi'] ?? json['name'] ?? '',
      nameEn: json['IlceAdiEn'] ?? json['nameEn'] ?? '',
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'parentId': parentId,
    };
  }
}