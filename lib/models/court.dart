/// A playing venue/court where matches take place.
class Court {
  final String id;
  final String name;
  final List<String> sports;
  final String? locationName;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String? zoneId;

  const Court({
    required this.id,
    required this.name,
    this.sports = const [],
    this.locationName,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.zoneId,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as String,
      name: json['name'] as String,
      sports: List<String>.from(json['sports'] ?? []),
      locationName: json['location_name'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoneId: json['zone_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sports': sports,
        'location_name': locationName,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'zone_id': zoneId,
      };
}
