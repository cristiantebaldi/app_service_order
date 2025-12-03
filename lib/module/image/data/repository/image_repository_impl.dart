import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:app_service_order/module/image/core/domain/model/image_entity.dart';
import 'package:app_service_order/module/image/data/datasource/image_dao.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final ImageDao dao;

  ImageRepositoryImpl({required this.dao});

  @override
  Future<int> insertImage(ImageEntity image) async {
    return await dao.insertImage(image);
  }

  @override
  Future<int> linkImageToServiceOrder({
    required int serviceOrderId,
    required int imageId,
  }) async {
    return await dao.linkImageToServiceOrder(
      serviceOrderId: serviceOrderId,
      imageId: imageId,
    );
  }

  @override
  Future<List<String>> fetchImagePaths(int serviceOrderId) async {
    return await dao.fetchImagePaths(serviceOrderId);
  }

  @override
  Future<int?> getImageIdByPath(String path) async {
    return await dao.getImageIdByPath(path);
  }

  @override
  Future<void> deleteImageLink({
    required int serviceOrderId,
    required int imageId,
  }) async {
    return await dao.deleteImageLink(
      serviceOrderId: serviceOrderId,
      imageId: imageId,
    );
  }
}
