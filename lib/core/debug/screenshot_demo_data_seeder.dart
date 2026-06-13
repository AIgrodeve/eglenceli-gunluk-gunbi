import 'package:flutter/foundation.dart';

import '../../features/journal/data/journal_repository.dart';
import '../../features/journal/models/journal_entry.dart';
import '../data/app_preferences.dart';
import '../models/age_group.dart';

class ScreenshotDemoDataSeeder {
  const ScreenshotDemoDataSeeder({
    this.preferences = const AppPreferences(),
    this.repository = const JournalRepository(),
  });

  final AppPreferences preferences;
  final JournalRepository repository;

  Future<void> seed({bool replaceExisting = false}) async {
    if (!kDebugMode) {
      throw StateError('Demo data seeding is only available in debug mode.');
    }

    final existingEntries = await repository.loadEntries();
    final hasExistingProfile =
        (await preferences.loadChildName()) != null ||
        (await preferences.loadChildAgeGroup()) != null;

    if (!replaceExisting &&
        (existingEntries.isNotEmpty || hasExistingProfile)) {
      throw StateError(
        'Demo data already exists or user data is present. '
        'Pass replaceExisting: true only on a dedicated screenshot device.',
      );
    }

    if (replaceExisting) {
      await repository.clearAllEntries();
      await preferences.clearLocalPreferences();
    }

    await preferences.completeOnboarding(
      childName: 'Meryem',
      childGender: 'Kız',
      ageGroup: AgeGroup.nineToEleven,
    );
    await preferences.updateBookTitle("Meryem'in Eğlenceli Günlüğü");

    for (final entry in _demoEntries()) {
      await repository.addEntry(entry);
    }
  }

  List<JournalEntry> _demoEntries() {
    final now = DateTime.now();

    return [
      JournalEntry(
        id: 'demo_entry_tatil',
        childName: 'Meryem',
        moodLabel: 'Enerjik',
        moodEmoji: '⚡',
        title: 'Tatil',
        promptText: 'Bugün yaşadığın en güzel anı detaylarıyla yaz.',
        text:
            'Bugün okul tatildi. Babam işten erken geldi. Parkta çok vakit geçirdik. Eve dönünce günlüğüme yazmak istediğim güzel anılar birikti.',
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      JournalEntry(
        id: 'demo_entry_parkta_bir_gun',
        childName: 'Meryem',
        moodLabel: 'Sakin',
        moodEmoji: '😌',
        title: 'Parkta Bir Gün',
        promptText: 'Bugün zorlandığın bir şey oldu mu? Nasıl hissettin?',
        text:
            'Hava çok sıcak olduğu için bazı arkadaşlarım parka gelmedi. Önce biraz üzüldüm ama sonra kitap okuyup salıncakta sallandım. Günüm yine güzel geçti.',
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      JournalEntry(
        id: 'demo_entry_bugun_kendimi_nasil_hissettim',
        childName: 'Meryem',
        moodLabel: 'Mutlu',
        moodEmoji: '😊',
        title: 'Bugün Kendimi Nasıl Hissettim?',
        promptText: 'Bugün seni düşündüren bir şey oldu mu?',
        text:
            'Bugün kendimi mutlu hissettim. Çünkü öğretmenim yazımı beğendi. Yazdıkça kendimi daha iyi anlatabildiğimi fark ettim.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      JournalEntry(
        id: 'demo_entry_kucuk_bir_basari',
        childName: 'Meryem',
        moodLabel: 'Heyecanlı',
        moodEmoji: '🤩',
        title: 'Küçük Bir Başarı',
        promptText: 'Bugün öğrendiğin bir şeyi kendi cümlelerinle anlat.',
        text:
            'Bugün yeni kelimeler öğrendim. Önce zor sandım ama sonra cümle içinde kullanınca daha kolay oldu. Günbi de bana yazarken yardımcı oldu.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
