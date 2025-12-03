import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:app_service_order/module/image/core/domain/model/image_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class InsertImageUsecase {
  final ImageRepository repository;

  InsertImageUsecase({required this.repository});

  Future<int> call(ImageEntity image) async {
    return await repository.insertImage(image);
  }
}
