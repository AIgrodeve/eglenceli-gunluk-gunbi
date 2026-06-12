import 'package:flutter/material.dart';

import '../../core/widgets/mascot_widget.dart';

class GunbiPage extends StatelessWidget {
  const GunbiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günbi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MascotWidget(),
              const SizedBox(height: 24),
              Text(
                'Sen yazdıkça Günbi de büyüyecek!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
