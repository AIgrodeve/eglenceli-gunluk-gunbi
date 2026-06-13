import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

import '../theme/app_theme.dart';

enum MascotMood {
  happy,
  excited,
  calm,
  supportive,
  sleepy,
  proud,
  writing,
  celebration,
}

enum MascotAnimationType { none, rive, lottie }

class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.size = 150,
    this.mood = MascotMood.happy,
    this.showShadow = true,
    this.showSparkles,
    this.animationType = MascotAnimationType.none,
    this.animationAsset,
    this.fallbackToStatic = true,
  });

  final double size;
  final MascotMood mood;
  final bool showShadow;
  final bool? showSparkles;
  final MascotAnimationType animationType;
  final String? animationAsset;
  final bool fallbackToStatic;

  @override
  Widget build(BuildContext context) {
    // Rive veya Lottie animasyonu geldiğinde sadece bu merkezi içerik değişir.
    return Semantics(
      label: 'Günbi maskotu',
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        scale: _scale,
        curve: Curves.easeOutBack,
        child: _buildMascot(),
      ),
    );
  }

  Widget _buildMascot() {
    final asset = _resolvedAnimationAsset;

    return switch (animationType) {
      MascotAnimationType.none => _buildStaticMascot(),
      MascotAnimationType.rive =>
        asset == null
            ? _buildFallbackMascot('Rive animasyon dosyası seçilmedi.')
            : _buildRiveMascot(asset),
      MascotAnimationType.lottie =>
        asset == null
            ? _buildFallbackMascot('Lottie animasyon dosyası seçilmedi.')
            : _buildLottieMascot(asset),
    };
  }

  Widget _buildStaticMascot() {
    return _StaticGunbiDrawing(
      size: size,
      mood: mood,
      showShadow: showShadow,
      showSparkles: showSparkles ?? _defaultSparkles,
    );
  }

  Widget _buildRiveMascot(String asset) {
    return _AnimationAssetGuard(
      asset: asset,
      fallback: _buildSilentFallbackMascot(),
      debugMessage: _fallbackDebugMessage(
        'Rive animasyonu yüklenemedi: $asset',
      ),
      builder: (_) => SizedBox(
        width: size,
        height: size,
        child: RiveAnimation.asset(
          asset,
          fit: BoxFit.contain,
          // İleride gerekirse stateMachines: ['GunbiStateMachine'] eklenebilir.
        ),
      ),
    );
  }

  Widget _buildLottieMascot(String asset) {
    return _AnimationAssetGuard(
      asset: asset,
      fallback: _buildSilentFallbackMascot(),
      debugMessage: _fallbackDebugMessage(
        'Lottie animasyonu yüklenemedi: $asset',
      ),
      builder: (_) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset(
              asset,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              errorBuilder: (_, error, stackTrace) {
                debugPrint('Günbi Lottie animasyonu açılamadı: $error');
                return _buildFallbackMascot(
                  'Lottie animasyonu açılamadı: $asset',
                );
              },
            ),
            IgnorePointer(
              child: _MascotFaceOverlay(size: size, mood: mood),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackMascot(String debugMessage) {
    if (!fallbackToStatic) {
      debugPrint(debugMessage);
      return SizedBox(width: size, height: size);
    }

    debugPrint('$debugMessage Statik Günbi gösteriliyor.');
    return _buildStaticMascot();
  }

  Widget _buildSilentFallbackMascot() {
    if (!fallbackToStatic) {
      return SizedBox(width: size, height: size);
    }
    return _buildStaticMascot();
  }

  String _fallbackDebugMessage(String message) {
    if (!fallbackToStatic) {
      return message;
    }
    return '$message Statik Günbi gösteriliyor.';
  }

  String? get _resolvedAnimationAsset {
    final explicitAsset = animationAsset?.trim();
    if (explicitAsset != null && explicitAsset.isNotEmpty) {
      return explicitAsset;
    }
    return _assetForMood(mood, animationType);
  }

  String? _assetForMood(MascotMood mood, MascotAnimationType type) {
    if (type == MascotAnimationType.none) {
      return null;
    }

    final moodName = switch (mood) {
      MascotMood.writing => 'writing',
      MascotMood.celebration => 'celebration',
      MascotMood.happy || MascotMood.excited || MascotMood.proud => 'happy',
      MascotMood.calm || MascotMood.supportive || MascotMood.sleepy => 'idle',
    };

    return switch (type) {
      MascotAnimationType.rive => 'assets/animations/rive/gunbi_$moodName.riv',
      MascotAnimationType.lottie =>
        'assets/animations/lottie/gunbi_$moodName.json',
      MascotAnimationType.none => null,
    };
  }

  double get _scale {
    return switch (mood) {
      MascotMood.excited || MascotMood.celebration => 1.03,
      MascotMood.sleepy || MascotMood.calm => 0.98,
      _ => 1,
    };
  }

  bool get _defaultSparkles {
    return switch (mood) {
      MascotMood.excited || MascotMood.proud || MascotMood.celebration => true,
      _ => false,
    };
  }
}

class _AnimationAssetGuard extends StatelessWidget {
  const _AnimationAssetGuard({
    required this.asset,
    required this.builder,
    required this.fallback,
    required this.debugMessage,
  });

  final String asset;
  final WidgetBuilder builder;
  final Widget fallback;
  final String debugMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteData>(
      future: rootBundle.load(asset),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return fallback;
        }
        if (snapshot.hasError || !snapshot.hasData) {
          debugPrint(debugMessage);
          return fallback;
        }
        return builder(context);
      },
    );
  }
}

class _MascotFaceOverlay extends StatelessWidget {
  const _MascotFaceOverlay({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    final colors = _MascotColors.forMood(mood);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.33,
            left: size * 0.36,
            child: _Eye(size: size * 0.74, mood: mood),
          ),
          Positioned(
            top: size * 0.33,
            right: size * 0.36,
            child: _Eye(size: size * 0.74, mood: mood),
          ),
          if (mood != MascotMood.sleepy)
            Positioned(
              top: size * 0.47,
              left: size * 0.28,
              child: _Cheek(size: size * 0.8, color: colors.cheek),
            ),
          if (mood != MascotMood.sleepy)
            Positioned(
              top: size * 0.47,
              right: size * 0.28,
              child: _Cheek(size: size * 0.8, color: colors.cheek),
            ),
          Positioned(
            bottom: size * 0.32,
            child: _Mouth(size: size * 0.78, mood: mood, color: colors.accent),
          ),
        ],
      ),
    );
  }
}

class _StaticGunbiDrawing extends StatelessWidget {
  const _StaticGunbiDrawing({
    required this.size,
    required this.mood,
    required this.showShadow,
    required this.showSparkles,
  });

  final double size;
  final MascotMood mood;
  final bool showShadow;
  final bool showSparkles;

  @override
  Widget build(BuildContext context) {
    final colors = _MascotColors.forMood(mood);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (showSparkles) ...[
            Positioned(
              top: size * 0.04,
              right: size * 0.06,
              child: _Sparkle(size: size * 0.16, color: colors.sparkle),
            ),
            Positioned(
              bottom: size * 0.12,
              left: size * 0.03,
              child: _Sparkle(size: size * 0.12, color: colors.sparkle),
            ),
          ],
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.body,
              borderRadius: BorderRadius.circular(size * 0.34),
              border: Border.all(color: colors.border, width: size * 0.018),
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                        color: AppTheme.lightOrange.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (mood == MascotMood.proud)
                  Positioned(
                    top: size * 0.13,
                    child: Container(
                      width: size * 0.42,
                      height: size * 0.08,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                Positioned(
                  top: size * 0.24,
                  left: size * 0.27,
                  child: _Eye(size: size, mood: mood),
                ),
                Positioned(
                  top: size * 0.24,
                  right: size * 0.27,
                  child: _Eye(size: size, mood: mood),
                ),
                if (mood != MascotMood.sleepy)
                  Positioned(
                    top: size * 0.43,
                    left: size * 0.18,
                    child: _Cheek(size: size, color: colors.cheek),
                  ),
                if (mood != MascotMood.sleepy)
                  Positioned(
                    top: size * 0.43,
                    right: size * 0.18,
                    child: _Cheek(size: size, color: colors.cheek),
                  ),
                Positioned(
                  bottom: size * 0.28,
                  child: _Mouth(size: size, mood: mood, color: colors.accent),
                ),
                if (mood == MascotMood.writing)
                  Positioned(
                    bottom: size * 0.1,
                    right: size * 0.16,
                    child: _Pencil(size: size),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    if (mood == MascotMood.sleepy) {
      return Container(
        width: size * 0.15,
        height: size * 0.035,
        decoration: BoxDecoration(
          color: AppTheme.cocoa,
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    final eyeSize = switch (mood) {
      MascotMood.excited || MascotMood.celebration => size * 0.12,
      MascotMood.calm || MascotMood.supportive => size * 0.09,
      _ => size * 0.1,
    };

    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: AppTheme.cocoa,
        shape: BoxShape.circle,
      ),
      child: mood == MascotMood.excited || mood == MascotMood.celebration
          ? Align(
              alignment: Alignment.topRight,
              child: Container(
                width: eyeSize * 0.32,
                height: eyeSize * 0.32,
                margin: EdgeInsets.all(eyeSize * 0.16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _Cheek extends StatelessWidget {
  const _Cheek({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.12,
      height: size * 0.07,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  const _Mouth({required this.size, required this.mood, required this.color});

  final double size;
  final MascotMood mood;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = switch (mood) {
      MascotMood.excited || MascotMood.celebration => size * 0.4,
      MascotMood.proud => size * 0.32,
      MascotMood.sleepy => size * 0.22,
      _ => size * 0.34,
    };
    final height = switch (mood) {
      MascotMood.calm || MascotMood.supportive => size * 0.08,
      MascotMood.sleepy => size * 0.035,
      MascotMood.proud => size * 0.06,
      _ => size * 0.13,
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: mood == MascotMood.sleepy || mood == MascotMood.proud
            ? BorderRadius.circular(999)
            : const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.18,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Container(
            width: size,
            height: size * 0.18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pencil extends StatelessWidget {
  const _Pencil({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        width: size * 0.26,
        height: size * 0.055,
        decoration: BoxDecoration(
          color: AppTheme.softBlue,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.cocoa.withValues(alpha: 0.25)),
        ),
      ),
    );
  }
}

class _MascotColors {
  const _MascotColors({
    required this.body,
    required this.accent,
    required this.border,
    required this.cheek,
    required this.sparkle,
  });

  final Color body;
  final Color accent;
  final Color border;
  final Color cheek;
  final Color sparkle;

  factory _MascotColors.forMood(MascotMood mood) {
    return switch (mood) {
      MascotMood.excited => const _MascotColors(
        body: Color(0xFFFFE58A),
        accent: AppTheme.lightOrange,
        border: Color(0xFFFFC24C),
        cheek: Color(0xFFFFA8B7),
        sparkle: Color(0xFFFFB56B),
      ),
      MascotMood.calm => const _MascotColors(
        body: Color(0xFFFFF1B8),
        accent: Color(0xFFFFC982),
        border: Color(0xFFFFDFA0),
        cheek: Color(0xFFFFC7C7),
        sparkle: AppTheme.softBlue,
      ),
      MascotMood.supportive => const _MascotColors(
        body: Color(0xFFFFEDAC),
        accent: Color(0xFFFFB56B),
        border: Color(0xFFFFD966),
        cheek: Color(0xFFFFB8C5),
        sparkle: AppTheme.softBlue,
      ),
      MascotMood.sleepy => const _MascotColors(
        body: Color(0xFFFFEFC4),
        accent: Color(0xFFD8B66D),
        border: Color(0xFFEAD59C),
        cheek: Color(0xFFDCCFC0),
        sparkle: Color(0xFFB8DDF6),
      ),
      MascotMood.proud => const _MascotColors(
        body: Color(0xFFFFDF78),
        accent: Color(0xFFE99A4D),
        border: Color(0xFFFFB84D),
        cheek: Color(0xFFFFA5B8),
        sparkle: Color(0xFFFFD966),
      ),
      MascotMood.writing => const _MascotColors(
        body: Color(0xFFFFE8A3),
        accent: AppTheme.lightOrange,
        border: Color(0xFFFFD966),
        cheek: Color(0xFFFFB7B7),
        sparkle: AppTheme.softBlue,
      ),
      MascotMood.celebration => const _MascotColors(
        body: Color(0xFFFFE171),
        accent: Color(0xFFFF9F5A),
        border: Color(0xFFFFB000),
        cheek: Color(0xFFFF91A8),
        sparkle: Color(0xFFFFC107),
      ),
      MascotMood.happy => const _MascotColors(
        body: AppTheme.pastelYellow,
        accent: AppTheme.lightOrange,
        border: Color(0xFFFFD966),
        cheek: Color(0xFFFFB6C1),
        sparkle: AppTheme.softBlue,
      ),
    };
  }
}
