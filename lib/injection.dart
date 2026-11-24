import 'package:get_it/get_it.dart';
import 'package:easefx_ai/core/network/dio_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<DioClient>(() => DioClient());
}
