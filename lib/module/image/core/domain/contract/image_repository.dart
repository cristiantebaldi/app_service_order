import 'package:app_service_order/module/image/core/domain/model/image_entity.dart';

abstract class ImageRepository {
  Future<int> insertImage(ImageEntity image);
  Future<int> linkImageToServiceOrder({
    required int serviceOrderId,
    required int imageId,
  });
  Future<List<String>> fetchImagePaths(int serviceOrderId);
  Future<int?> getImageIdByPath(String path);
  Future<void> deleteImageLink({
    required int serviceOrderId,
    required int imageId,
  });
}
