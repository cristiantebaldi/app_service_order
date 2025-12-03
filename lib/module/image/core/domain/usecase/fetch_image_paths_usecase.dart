import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchImagePathsUsecase {
  final ImageRepository repository;

  FetchImagePathsUsecase({required this.repository});

  Future<List<String>> call(int serviceOrderId) async {
    return await repository.fetchImagePaths(serviceOrderId);
  }
}
