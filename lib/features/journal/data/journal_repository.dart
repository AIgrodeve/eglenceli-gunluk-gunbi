import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

class JournalRepository {
  const JournalRepository();

  static const _entriesKey = 'journal_entries';

  Future<List<JournalEntry>> loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final rawEntries = preferences.getString(_entriesKey);
    if (rawEntries == null || rawEntries.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawEntries) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(JournalEntry.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addEntry(JournalEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    entries.insert(0, entry);

    final encodedEntries = jsonEncode(
      entries.map((journalEntry) => journalEntry.toJson()).toList(),
    );
    await preferences.setString(_entriesKey, encodedEntries);
  }
}
