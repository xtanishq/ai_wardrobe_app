import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                      ).createShader(bounds),
                      child: Text(
                        "Glimora AI",
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "AI-powered photo studio",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── 1. FEATURED — Hero Banner ─────────────
              _sectionTitle("Featured"),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PageView(
                  controller: PageController(viewportFraction: 0.96),
                  children: [
                    _heroBanner(
                      asset: "asset/clothchnage.png",
                      title: "Cloth Changer",
                      subtitle: "Try outfits instantly",
                      onTap: () => _goTo('/editor'),
                    ),
                    _heroBanner(
                      asset: "asset/aifilter.png",
                      title: "AI Filters",
                      subtitle: "Stunning creative styles",
                      onTap: () => _goTo('/ai-filters'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── 2. AI GENERATION ──────────────────────
              _sectionTitle("AI Generation"),
              const SizedBox(height: 12),
              _horizontalScroll([
                _compactCard(
                  asset: "asset/texttoimage.png",
                  label: "Text → Image",
                  onTap: () => _goTo('/text-to-image'),
                ),
                _compactCard(
                  asset: "asset/textandimg.png",
                  label: "Image + Text",
                  onTap: () => _goTo('/image-and-text'),
                ),
              ]),

              const SizedBox(height: 28),

              // ─── 3. RETOUCH & ENHANCE ──────────────────
              _sectionTitle("Retouch & Enhance"),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: PageView(
                  controller: PageController(viewportFraction: 0.96),
                  children: [
                    _heroBanner(
                      asset: "asset/enhance.png",
                      title: "AI Enhance",
                      subtitle: "Upscale & sharpen photos",
                      onTap: () => _goTo('/enhance'),
                    ),
                    _heroBanner(
                      asset: "asset/removebg.png",
                      title: "Remove BG",
                      subtitle: "Clean background removal",
                      onTap: () => _goTo('/remove-background'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── 4. STYLE TRANSFER ─────────────────────
              _sectionTitle("Style Transfer"),
              const SizedBox(height: 12),
              _horizontalScroll([
                _compactCard(
                  asset: "asset/hairswap.png",
                  label: "Hair Swap",
                  onTap: () => _goTo('/hair-swap'),
                ),
                _compactCard(
                  asset: "asset/texttoimage.png",
                  label: "Art Styles",
                  onTap: () => _goTo('/art-styles'),
                ),
                _compactCard(
                  asset: "asset/kontextflux.png",
                  label: "Kontext Flux",
                  onTap: () => _goTo('/kontext-flux'),
                ),
              ]),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/creations');
        },
      ),
    );
  }

  void _goTo(String route) => context.push(route);

  // ═══════════════════════════════════════════════════════════════
  //  WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMain,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Full-width hero banner used in the PageView carousel.
  Widget _heroBanner({
    required String asset,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          image: DecorationImage(
            image: AssetImage(asset),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontally scrolling list wrapper.
  Widget _horizontalScroll(List<Widget> children) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }

  /// Compact card for horizontal scroll lists.
  Widget _compactCard({
    required String asset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  image: DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    // colorFilter: ColorFilter.mode(
                    //   Colors.black.withOpacity(0.35),
                    //   BlendMode.darken,
                    // ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMain,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 2-column grid card for the Retouch section.
  Widget _gridCard({
    required String asset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderSubtle, width: 1),
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.15),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
