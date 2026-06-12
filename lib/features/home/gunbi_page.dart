import 'package:flutter/material.dart';

import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../rewards/models/gunbi_growth.dart';
import '../rewards/models/journal_stats.dart';

class GunbiPage extends StatelessWidget {
  const GunbiPage({super.key});

  @override
  Widget build(BuildContext context) {
    const repository = JournalRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Günbi')),
      body: SafeArea(
        child: FutureBuilder<JournalStats>(
          future: repository.loadEntries().then(JournalStats.fromEntries),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data ?? JournalStats.fromEntries([]);
            final growth = GunbiGrowth.fromEntryCount(stats.totalEntries);

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MascotWidget(size: 170),
                    const SizedBox(height: 28),
                    Text(
                      growth.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      growth.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
