class Place {
  final String name;
  final String address;
  final List<String> keywords;
  final double latitude;
  final double longitude;
  final String imageUrl;

  Place({
    required this.name,
    required this.address,
    required this.keywords,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      address: json['address'],
      keywords: List<String>.from(json['keywords']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['image_url'],
    );
  }
}
