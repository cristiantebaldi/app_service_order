class ImageEntity {
  final int? id;
  final String path;
  final int serviceOrderId;
  final DateTime createdDate;

  ImageEntity({
    this.id,
    required this.path,
    required this.serviceOrderId,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'service_order_id': serviceOrderId,
      'created_date': createdDate.millisecondsSinceEpoch,
    };
  }

  factory ImageEntity.fromMap(Map<String, dynamic> map) {
    return ImageEntity(
      id: map['id'] as int?,
      path: map['path'] as String,
      serviceOrderId: map['service_order_id'] as int,
      createdDate: DateTime.fromMillisecondsSinceEpoch(
        map['created_date'] as int,
      ),
    );
  }
}
