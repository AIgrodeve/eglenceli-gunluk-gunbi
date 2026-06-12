import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum MascotMood { happy, calm }

class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.size = 150,
    this.mood = MascotMood.happy,
  });

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    // Rive veya Lottie animasyonu geldiğinde sadece bu içeriği değiştirmek yeterli.
    return Semantics(
      label: 'Günbi maskotu',
      child: _StaticGunbiDrawing(size: size, mood: mood),
    );
  }
}

class _StaticGunbiDrawing extends StatelessWidget {
  const _StaticGunbiDrawing({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.pastelYellow,
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightOrange.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.24,
            left: size * 0.27,
            child: _Eye(size: size),
          ),
          Positioned(
            top: size * 0.24,
            right: size * 0.27,
            child: _Eye(size: size),
          ),
          Positioned(
            bottom: size * 0.3,
            child: _Mouth(size: size, mood: mood),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.1,
      height: size * 0.1,
      decoration: const BoxDecoration(
        color: AppTheme.cocoa,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Mouth extends StatelessWidget {
  const _Mouth({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    final height = mood == MascotMood.calm ? size * 0.08 : size * 0.13;

    return Container(
      width: size * 0.34,
      height: height,
      decoration: const BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }
}
