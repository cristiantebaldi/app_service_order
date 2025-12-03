import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteImageUsecase {
  final ImageRepository repository;

  DeleteImageUsecase({required this.repository});

  Future<void> call({required int serviceOrderId, required int imageId}) async {
    return await repository.deleteImageLink(
      serviceOrderId: serviceOrderId,
      imageId: imageId,
    );
  }
}
