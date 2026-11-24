import 'package:go_router/go_router.dart';
import 'package:easefx_ai/features/onboarding/presentation/pages/splash_page.dart';
import 'package:easefx_ai/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:easefx_ai/features/home/presentation/pages/home_page.dart';
import 'package:easefx_ai/features/editor/presentation/pages/editor_page.dart';
import 'package:easefx_ai/features/editor/presentation/pages/processing_page.dart';
import 'package:easefx_ai/features/editor/presentation/pages/result_page.dart';
import 'package:easefx_ai/features/creations/presentation/pages/my_creations_page.dart';
import 'package:easefx_ai/features/ai_filters/presentation/pages/ai_filters_page.dart';
import 'package:easefx_ai/features/hair_swap/presentation/pages/hair_swap_page.dart';
import 'package:easefx_ai/features/image_edit/text_to_image/presentation/pages/text_to_image_page.dart';
import 'package:easefx_ai/features/creations/presentation/pages/image_preview_page.dart';
import 'package:easefx_ai/features/kontext_flux/presentation/pages/kontext_flux_page.dart';
import 'package:easefx_ai/features/image_edit/image_and_text/presentation/pages/image_and_text_page.dart';
import 'package:easefx_ai/features/image_edit/art_styles/presentation/pages/art_styles_page.dart';
import 'package:easefx_ai/features/image_edit/enhance/presentation/pages/enhance_page.dart';
import 'package:easefx_ai/features/image_edit/remove_background/presentation/pages/remove_background_page.dart';
import 'package:easefx_ai/features/image_edit/remove_background/presentation/pages/add_background_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const EditorPage(),
    ),
    GoRoute(
      path: '/ai-filters',
      builder: (context, state) => const AiFiltersPage(),
    ),
    GoRoute(
      path: '/hair-swap',
      builder: (context, state) => const HairSwapPage(),
    ),
    // GoRoute(
    //   path: '/headshot',
    //   builder: (context, state) {
    //     return BlocProvider(
    //       create: (context) => getIt<HeadshotGeneratorBloc>(),
    //       child: const HeadshotGeneratorPage(),
    //     );
    //   },
    // ),
    GoRoute(
      path: '/processing',
      builder: (context, state) => const ProcessingPage(),
    ),
    GoRoute(
      path: '/result',
      redirect: (context, state) => _hasResultUrl(state.extra) ? null : '/home',
      builder: (context, state) {
        final extraData = Map<String, dynamic>.from(state.extra! as Map);
        return ResultPage(extraData: extraData);
      },
    ),
    GoRoute(
      path: '/creations',
      builder: (context, state) => const MyCreationsPage(),
    ),
    GoRoute(
      path: '/text-to-image',
      builder: (context, state) => const TextToImagePage(),
    ),
    GoRoute(
      path: '/image-preview',
      redirect: (context, state) =>
          _isWebUrl(state.extra) ? null : '/creations',
      builder: (context, state) {
        final imageUrl = state.extra as String;
        return ImagePreviewPage(imageUrl: imageUrl);
      },
    ),
    GoRoute(
      path: '/kontext-flux',
      builder: (context, state) => const KontextFluxPage(),
    ),
    GoRoute(
      path: '/image-and-text',
      builder: (context, state) => const ImageAndTextPage(),
    ),
    GoRoute(
      path: '/enhance',
      builder: (context, state) => const EnhancePage(),
    ),
    GoRoute(
      path: '/remove-background',
      builder: (context, state) => const RemoveBackgroundPage(),
    ),
    GoRoute(
      path: '/add-background',
      redirect: (context, state) =>
          _hasBackgroundExtras(state.extra) ? null : '/home',
      builder: (context, state) {
        final extras = Map<String, dynamic>.from(state.extra! as Map);
        return AddBackgroundPage(
          resultUrl: extras['resultUrl'] as String,
          originalPath: extras['originalPath'] as String,
        );
      },
    ),
    GoRoute(
      path: '/art-styles',
      builder: (context, state) => const ArtStylesPage(),
    ),
  ],
);

bool _hasResultUrl(Object? extra) {
  if (extra is! Map) return false;
  return _isWebUrl(extra['resultUrl']);
}

bool _hasBackgroundExtras(Object? extra) {
  if (!_hasResultUrl(extra) || extra is! Map) return false;
  final originalPath = extra['originalPath'];
  return originalPath is String && originalPath.trim().isNotEmpty;
}

bool _isWebUrl(Object? value) {
  if (value is! String) return false;
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty;
}
