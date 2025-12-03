// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_service_order/core/di/register_module.dart' as _i50;
import 'package:app_service_order/module/home/controller/create_service_order_cubit.dart'
    as _i482;
import 'package:app_service_order/module/home/controller/edit_service_order_cubit.dart'
    as _i571;
import 'package:app_service_order/module/home/controller/home_controller.dart'
    as _i159;
import 'package:app_service_order/module/home/core/domain/contract/change_service_order_repository.dart'
    as _i783;
import 'package:app_service_order/module/home/core/domain/contract/create_service_order_repository.dart'
    as _i359;
import 'package:app_service_order/module/home/core/domain/contract/delete_service_order_repository.dart'
    as _i138;
import 'package:app_service_order/module/home/core/domain/contract/fetch_service_order_repository.dart'
    as _i1007;
import 'package:app_service_order/module/home/core/domain/contract/get_by_id_service_order_repository.dart'
    as _i784;
import 'package:app_service_order/module/home/core/domain/usecase/change_service_order_usecase.dart'
    as _i1007;
import 'package:app_service_order/module/home/core/domain/usecase/create_service_order_usecase.dart'
    as _i56;
import 'package:app_service_order/module/home/core/domain/usecase/delete_service_order_usecase.dart'
    as _i902;
import 'package:app_service_order/module/home/core/domain/usecase/fetch_service_order_usecase.dart'
    as _i714;
import 'package:app_service_order/module/home/core/domain/usecase/get_by_id_service_order_usecase.dart'
    as _i915;
import 'package:app_service_order/module/home/data/repository/change_service_order_repository.dart'
    as _i687;
import 'package:app_service_order/module/home/data/repository/create_service_order_repository.dart'
    as _i126;
import 'package:app_service_order/module/home/data/repository/delete_service_order_repository.dart'
    as _i230;
import 'package:app_service_order/module/home/data/repository/fetch_service_order_repository.dart'
    as _i198;
import 'package:app_service_order/module/home/data/repository/get_by_id_service_order_repository.dart'
    as _i311;
import 'package:app_service_order/module/image/core/domain/contract/image_repository.dart'
    as _i729;
import 'package:app_service_order/module/image/core/domain/usecase/delete_image_usecase.dart'
    as _i365;
import 'package:app_service_order/module/image/core/domain/usecase/fetch_image_paths_usecase.dart'
    as _i99;
import 'package:app_service_order/module/image/core/domain/usecase/get_image_id_by_path_usecase.dart'
    as _i945;
import 'package:app_service_order/module/image/core/domain/usecase/insert_image_usecase.dart'
    as _i385;
import 'package:app_service_order/module/image/core/domain/usecase/link_image_to_service_order_usecase.dart'
    as _i647;
import 'package:app_service_order/module/image/data/datasource/image_dao.dart'
    as _i1005;
import 'package:app_service_order/module/image/data/repository/image_repository_impl.dart'
    as _i749;
import 'package:app_service_order/module/navigation/navigation_cubit.dart'
    as _i395;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;
import 'package:sqflite/sqlite_api.dart' as _i232;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i779.Database>(
      () => registerModule.database,
      preResolve: true,
    );
    gh.factory<_i395.NavigationCubit>(() => _i395.NavigationCubit());
    gh.factory<_i1005.ImageDao>(
      () => _i1005.ImageDao(db: gh<_i779.Database>()),
    );
    gh.factory<_i359.CreateServiceOrderRepository>(
      () => _i126.CreateServiceOrderRepositoryImpl(db: gh<_i232.Database>()),
    );
    gh.factory<_i1007.FetchServiceOrderRepository>(
      () => _i198.FetchServiceOrderRepositoryImpl(db: gh<_i232.Database>()),
    );
    gh.factory<_i784.GetByIDServiceOrderRepository>(
      () => _i311.GetByIDServiceOrderRepositoryImpl(db: gh<_i232.Database>()),
    );
    gh.factory<_i729.ImageRepository>(
      () => _i749.ImageRepositoryImpl(dao: gh<_i1005.ImageDao>()),
    );
    gh.factory<_i56.CreateServiceOrderUsecase>(
      () => _i56.CreateServiceOrderUsecase(
        createServiceOrderRepository: gh<_i359.CreateServiceOrderRepository>(),
      ),
    );
    gh.factory<_i783.ChangeServiceOrderRepository>(
      () => _i687.ChangeServiceOrderRepositoryImpl(db: gh<_i232.Database>()),
    );
    gh.factory<_i138.DeleteServiceOrderRepository>(
      () => _i230.DeleteServiceOrderRepositoryImpl(db: gh<_i232.Database>()),
    );
    gh.factory<_i365.DeleteImageUsecase>(
      () => _i365.DeleteImageUsecase(repository: gh<_i729.ImageRepository>()),
    );
    gh.factory<_i99.FetchImagePathsUsecase>(
      () =>
          _i99.FetchImagePathsUsecase(repository: gh<_i729.ImageRepository>()),
    );
    gh.factory<_i945.GetImageIdByPathUsecase>(
      () => _i945.GetImageIdByPathUsecase(
        repository: gh<_i729.ImageRepository>(),
      ),
    );
    gh.factory<_i385.InsertImageUsecase>(
      () => _i385.InsertImageUsecase(repository: gh<_i729.ImageRepository>()),
    );
    gh.factory<_i647.LinkImageToServiceOrderUsecase>(
      () => _i647.LinkImageToServiceOrderUsecase(
        repository: gh<_i729.ImageRepository>(),
      ),
    );
    gh.factory<_i714.FetchServiceOrderUsecase>(
      () => _i714.FetchServiceOrderUsecase(
        fetchServiceOrderRepository: gh<_i1007.FetchServiceOrderRepository>(),
      ),
    );
    gh.factory<_i902.DeleteServiceOrderUsecase>(
      () => _i902.DeleteServiceOrderUsecase(
        deleteServiceOrderRepository: gh<_i138.DeleteServiceOrderRepository>(),
      ),
    );
    gh.factory<_i482.CreateServiceOrderCubit>(
      () => _i482.CreateServiceOrderCubit(
        createServiceOrderUsecase: gh<_i56.CreateServiceOrderUsecase>(),
      ),
    );
    gh.factory<_i915.GetByIdServiceOrderUsecase>(
      () => _i915.GetByIdServiceOrderUsecase(
        getByIDServiceOrderRepository:
            gh<_i784.GetByIDServiceOrderRepository>(),
      ),
    );
    gh.factory<_i1007.ChangeServiceOrderUsecase>(
      () => _i1007.ChangeServiceOrderUsecase(
        changeServiceOrderRepository: gh<_i783.ChangeServiceOrderRepository>(),
      ),
    );
    gh.factory<_i571.EditServiceOrderCubit>(
      () => _i571.EditServiceOrderCubit(
        changeServiceOrderUsecase: gh<_i1007.ChangeServiceOrderUsecase>(),
      ),
    );
    gh.factory<_i159.HomeController>(
      () => _i159.HomeController(
        fetchServiceOrderUsecase: gh<_i714.FetchServiceOrderUsecase>(),
        createServiceOrderUsecase: gh<_i56.CreateServiceOrderUsecase>(),
        changeServiceOrderUsecase: gh<_i1007.ChangeServiceOrderUsecase>(),
        deleteServiceOrderUsecase: gh<_i902.DeleteServiceOrderUsecase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i50.RegisterModule {}
