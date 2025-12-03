import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetImageIdByPathUsecase {
  final ImageRepository repository;

  GetImageIdByPathUsecase({required this.repository});

  Future<int?> call(String path) async {
    return await repository.getImageIdByPath(path);
  }
}
