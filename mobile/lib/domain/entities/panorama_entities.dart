class PanoramaHotspotEntity {
  const PanoramaHotspotEntity({
    required this.fixtureId,
    required this.longitude,
    required this.latitude,
  });

  final String fixtureId;
  final double longitude;
  final double latitude;

  Map<String, Object> toJson() => {
    'fixtureId': fixtureId,
    'longitude': longitude,
    'latitude': latitude,
  };

  factory PanoramaHotspotEntity.fromJson(Map<String, Object?> json) =>
      PanoramaHotspotEntity(
        fixtureId: json['fixtureId']! as String,
        longitude: (json['longitude']! as num).toDouble(),
        latitude: (json['latitude']! as num).toDouble(),
      );
}

class PanoramaZoneEntity {
  const PanoramaZoneEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.imagePath,
    required this.thumbnailPath,
    required this.updatedAt,
    this.remoteImageUrl,
    this.hotspots = const [],
  });

  final String id;
  final String storeId;
  final String name;
  final String imagePath;
  final String thumbnailPath;
  final String? remoteImageUrl;
  final List<PanoramaHotspotEntity> hotspots;
  final DateTime updatedAt;

  PanoramaZoneEntity copyWith({
    String? name,
    String? imagePath,
    String? thumbnailPath,
    String? remoteImageUrl,
    List<PanoramaHotspotEntity>? hotspots,
    DateTime? updatedAt,
  }) => PanoramaZoneEntity(
    id: id,
    storeId: storeId,
    name: name ?? this.name,
    imagePath: imagePath ?? this.imagePath,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
    hotspots: hotspots ?? this.hotspots,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'storeId': storeId,
    'name': name,
    'imagePath': imagePath,
    'thumbnailPath': thumbnailPath,
    'remoteImageUrl': remoteImageUrl,
    'hotspots': hotspots.map((hotspot) => hotspot.toJson()).toList(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory PanoramaZoneEntity.fromJson(Map<String, Object?> json) =>
      PanoramaZoneEntity(
        id: json['id']! as String,
        storeId: json['storeId']! as String,
        name: json['name']! as String,
        imagePath: json['imagePath']! as String,
        thumbnailPath: json['thumbnailPath']! as String,
        remoteImageUrl: json['remoteImageUrl'] as String?,
        hotspots: (json['hotspots'] as List<Object?>? ?? const [])
            .map(
              (item) => PanoramaHotspotEntity.fromJson(
                Map<String, Object?>.from(item! as Map),
              ),
            )
            .toList(growable: false),
        updatedAt: DateTime.parse(json['updatedAt']! as String),
      );
}
