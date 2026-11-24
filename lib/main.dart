import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easefx_ai/core/routes/app_router.dart';
import 'package:easefx_ai/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easefx_ai/core/utils/app_bloc_observer.dart';
import 'package:easefx_ai/injection.dart';
import 'package:easefx_ai/core/data/creations_store.dart';
import 'package:easefx_ai/core/config/ai_runtime_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    CreationsStore().init(),
    AiRuntimeConfig.instance.initialize(),
  ]);
  configureDependencies();
  Bloc.observer = AppBlocObserver();

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const EaseFXApp());
}

class EaseFXApp extends StatelessWidget {
  const EaseFXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Glimora AI',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
