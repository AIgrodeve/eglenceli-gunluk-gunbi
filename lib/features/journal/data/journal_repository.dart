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
    final entries = decoded
        .whereType<Map<String, dynamic>>()
        .map(JournalEntry.fromJson)
        .toList();
    final normalizedEntries = _ensureEntryIds(entries);
    if (_hasMissingIds(entries)) {
      await _saveEntries(preferences, normalizedEntries);
    }

    return normalizedEntries
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addEntry(JournalEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    entries.insert(0, entry);

    await _saveEntries(preferences, entries);
  }

  Future<void> updateEntry(JournalEntry updatedEntry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    final updatedEntries = entries
        .map((entry) => entry.id == updatedEntry.id ? updatedEntry : entry)
        .toList();

    await _saveEntries(preferences, updatedEntries);
  }

  Future<void> deleteEntry(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    final updatedEntries = entries.where((entry) => entry.id != id).toList();

    await _saveEntries(preferences, updatedEntries);
  }

  Future<void> _saveEntries(
    SharedPreferences preferences,
    List<JournalEntry> entries,
  ) async {
    final encodedEntries = jsonEncode(
      entries.map((journalEntry) => journalEntry.toJson()).toList(),
    );
    await preferences.setString(_entriesKey, encodedEntries);
  }

  bool _hasMissingIds(List<JournalEntry> entries) {
    return entries.any((entry) => entry.id.trim().isEmpty);
  }

  List<JournalEntry> _ensureEntryIds(List<JournalEntry> entries) {
    return [
      for (var index = 0; index < entries.length; index++)
        entries[index].id.trim().isEmpty
            ? entries[index].copyWith(
                id: 'legacy_${entries[index].createdAt.microsecondsSinceEpoch}_$index',
              )
            : entries[index],
    ];
  }
}
