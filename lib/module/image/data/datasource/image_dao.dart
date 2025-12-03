import 'package:app_service_order/module/image/core/domain/model/image_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@injectable
class ImageDao {
  final Database db;

  ImageDao({required this.db});

  Future<int> insertImage(ImageEntity image) async {
    return await db.insert(
      'image',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> linkImageToServiceOrder({
    required int serviceOrderId,
    required int imageId,
  }) async {
    return await db.insert('service_order_image', {
      'service_order_id': serviceOrderId,
      'image_id': imageId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<String>> fetchImagePaths(int serviceOrderId) async {
    final rows = await db.rawQuery(
      'SELECT i.path FROM image i INNER JOIN service_order_image soi ON soi.image_id = i.id WHERE soi.service_order_id = ? ORDER BY i.created_date ASC',
      [serviceOrderId],
    );
    return rows.map((e) => e['path'] as String).toList();
  }

  Future<int?> getImageIdByPath(String path) async {
    final rows = await db.query(
      'image',
      where: 'path = ?',
      whereArgs: [path],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  Future<void> deleteImageLink({
    required int serviceOrderId,
    required int imageId,
  }) async {
    await db.delete(
      'service_order_image',
      where: 'service_order_id = ? AND image_id = ?',
      whereArgs: [serviceOrderId, imageId],
    );
    await db.delete('image', where: 'id = ?', whereArgs: [imageId]);
  }
}
