import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LinkImageToServiceOrderUsecase {
  final ImageRepository repository;

  LinkImageToServiceOrderUsecase({required this.repository});

  Future<int> call({required int serviceOrderId, required int imageId}) async {
    return await repository.linkImageToServiceOrder(
      serviceOrderId: serviceOrderId,
      imageId: imageId,
    );
  }
}
