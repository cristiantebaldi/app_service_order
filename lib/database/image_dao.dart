import 'package:app_service_order/database/db.dart';
import 'package:sqflite/sqflite.dart';

class ImageDao {
  Future<int> insertImage({required String path, required DateTime createdDate}) async {
    final Database db = await DB.instance.database;
    return await db.insert(
      'image',
      {
        'path': path,
        'created_date': createdDate.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> linkImageToServiceOrder({required int serviceOrderId, required int imageId}) async {
    final Database db = await DB.instance.database;
    return await db.insert(
      'service_order_image',
      {
        'service_order_id': serviceOrderId,
        'image_id': imageId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> fetchImagePathsForServiceOrder(int serviceOrderId) async {
    final Database db = await DB.instance.database;
    final rows = await db.rawQuery(
      'SELECT i.path FROM image i INNER JOIN service_order_image soi ON soi.image_id = i.id WHERE soi.service_order_id = ? ORDER BY i.created_date ASC',
      [serviceOrderId],
    );
    return rows.map((e) => e['path'] as String).toList();
  }

  Future<int?> getImageIdByPath(String path) async {
    final Database db = await DB.instance.database;
    final rows = await db.query('image', where: 'path = ?', whereArgs: [path], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  Future<void> deleteLinkAndImage({required int serviceOrderId, required int imageId}) async {
    final Database db = await DB.instance.database;
    await db.delete('service_order_image', where: 'service_order_id = ? AND image_id = ?', whereArgs: [serviceOrderId, imageId]);
    await db.delete('image', where: 'id = ?', whereArgs: [imageId]);
  }
}
