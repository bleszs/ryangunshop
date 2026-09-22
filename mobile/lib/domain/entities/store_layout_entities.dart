enum StoreFixtureType { shelf, cabinet, refrigerator, cashier, display }

class StoreLayoutEntity {
  const StoreLayoutEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.canvasAspectRatio,
    required this.templateVersion,
    required this.fixtures,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String name;
  final double canvasAspectRatio;
  final int templateVersion;
  final List<StoreFixture> fixtures;
  final DateTime updatedAt;
}

class StoreFixture {
  const StoreFixture({
    required this.id,
    required this.type,
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotationQuarterTurns = 0,
    this.productIds = const [],
    this.panoramaZoneId,
  });

  final String id;
  final StoreFixtureType type;
  final String label;
  final double x;
  final double y;
  final double width;
  final double height;
  final int rotationQuarterTurns;
  final List<String> productIds;
  final String? panoramaZoneId;

  StoreFixture copyWith({
    String? id,
    StoreFixtureType? type,
    String? label,
    double? x,
    double? y,
    double? width,
    double? height,
    int? rotationQuarterTurns,
    List<String>? productIds,
    String? panoramaZoneId,
  }) => StoreFixture(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label ?? this.label,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
    productIds: productIds ?? this.productIds,
    panoramaZoneId: panoramaZoneId ?? this.panoramaZoneId,
  );
}
