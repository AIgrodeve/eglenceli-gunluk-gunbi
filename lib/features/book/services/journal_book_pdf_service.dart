import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/models/age_group.dart';
import '../../journal/models/journal_entry.dart';
import '../../rewards/models/journal_stats.dart';

class JournalBookPdfService {
  const JournalBookPdfService();

  Future<Uint8List> buildPdf({
    required String bookTitle,
    required String childName,
    required AgeGroup ageGroup,
    required List<JournalEntry> entries,
    required JournalStats stats,
    required int writtenDayCount,
    required String mostFrequentMood,
    required int bestStreak,
    required DateTime? firstEntryDate,
    required DateTime? lastEntryDate,
  }) async {
    final fonts = await _loadFonts();
    final style = _PdfBookStyle.forAgeGroup(ageGroup);
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        italic: fonts.italic,
      ),
    );
    final sortedEntries = [...entries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    document.addPage(
      _buildCoverPage(
        style: style,
        bookTitle: bookTitle,
        childName: childName,
        ageGroup: ageGroup,
        createdAt: DateTime.now(),
      ),
    );
    document.addPage(
      _buildSummaryPage(
        style: style,
        stats: stats,
        writtenDayCount: writtenDayCount,
        mostFrequentMood: _stripEmojiPrefix(mostFrequentMood),
        bestStreak: bestStreak,
        firstEntryDate: firstEntryDate,
        lastEntryDate: lastEntryDate,
      ),
    );
    document.addPage(
      _buildEntriesPages(
        style: style,
        bookTitle: bookTitle,
        entries: sortedEntries,
      ),
    );

    return document.save();
  }

  Future<_PdfFonts> _loadFonts() async {
    // TODO: If these asset files are removed, add Turkish-capable TTF files
    // under assets/fonts and keep pubspec.yaml in sync.
    final regularData = await rootBundle.load(
      'assets/fonts/Roboto-Regular.ttf',
    );
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final italicData = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');

    return _PdfFonts(
      regular: pw.Font.ttf(regularData),
      bold: pw.Font.ttf(boldData),
      italic: pw.Font.ttf(italicData),
    );
  }

  pw.Page _buildCoverPage({
    required _PdfBookStyle style,
    required String bookTitle,
    required String childName,
    required AgeGroup ageGroup,
    required DateTime createdAt,
  }) {
    return pw.Page(
      pageTheme: _pageTheme(style),
      build: (context) {
        return _decoratedPage(
          style: style,
          child: pw.Center(
            child: pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 42,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(style.largeRadius),
                border: pw.Border.all(color: style.accent, width: 1.4),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  _miniFlowerRow(style),
                  pw.SizedBox(height: 22),
                  pw.Text(
                    bookTitle,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: style.coverTitleSize,
                      fontWeight: pw.FontWeight.bold,
                      color: style.titleColor,
                      lineSpacing: 6,
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    'Günbi ile yazı yolculuğum',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: style.subtitleSize,
                      color: style.accentDark,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    childName.trim().isEmpty ? 'Sevgili yazar' : childName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: style.titleColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    ageGroup.label,
                    style: pw.TextStyle(fontSize: 14, color: style.textColor),
                  ),
                  pw.SizedBox(height: 22),
                  pw.Text(
                    'Oluşturulma tarihi: ${_formatDate(createdAt)}',
                    style: pw.TextStyle(fontSize: 13, color: style.textColor),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'Yazmak bu kadar eğlenceli olabilir miydi?',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontStyle: pw.FontStyle.italic,
                      color: style.textSoft,
                    ),
                  ),
                  pw.SizedBox(height: 22),
                  _miniLeafLine(style),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  pw.Page _buildSummaryPage({
    required _PdfBookStyle style,
    required JournalStats stats,
    required int writtenDayCount,
    required String mostFrequentMood,
    required int bestStreak,
    required DateTime? firstEntryDate,
    required DateTime? lastEntryDate,
  }) {
    final items = [
      _SummaryItem('Yazı sayısı', '${stats.totalEntries}', '✎'),
      _SummaryItem('Kelime sayısı', '${stats.totalWords}', 'Aa'),
      _SummaryItem('Farklı gün sayısı', '$writtenDayCount', 'Takvim'),
      _SummaryItem('En sık duygu', mostFrequentMood, 'Duygu'),
      _SummaryItem('En iyi seri', '$bestStreak gün', 'Seri'),
      _SummaryItem(
        'İlk yazı tarihi',
        _formatNullableDate(firstEntryDate),
        'İlk',
      ),
      _SummaryItem(
        'Son yazı tarihi',
        _formatNullableDate(lastEntryDate),
        'Son',
      ),
    ];

    return pw.Page(
      pageTheme: _pageTheme(style),
      build: (context) {
        return _decoratedPage(
          style: style,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle('Kitap Özeti', style),
              pw.SizedBox(height: 18),
              pw.Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in items)
                    _summaryCard(item: item, style: style),
                ],
              ),
              pw.Spacer(),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: style.noteBackground,
                  borderRadius: pw.BorderRadius.circular(style.radius),
                  border: pw.Border.all(color: style.accentLight, width: 0.8),
                ),
                child: pw.Text(
                  'Kısa yazılar da kitabın güzel bir parçası.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontStyle: pw.FontStyle.italic,
                    color: style.textSoft,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.MultiPage _buildEntriesPages({
    required _PdfBookStyle style,
    required String bookTitle,
    required List<JournalEntry> entries,
  }) {
    return pw.MultiPage(
      pageTheme: _pageTheme(style),
      header: (context) => pw.Text(
        bookTitle,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: style.textSoft,
        ),
      ),
      build: (context) {
        return [
          _sectionTitle('Günlük Yazıları', style),
          pw.SizedBox(height: 14),
          for (final entry in entries) _entryCard(entry: entry, style: style),
        ];
      },
    );
  }

  pw.PageTheme _pageTheme(_PdfBookStyle style) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      buildBackground: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            color: style.pageBackground,
            border: pw.Border.all(color: style.frameColor, width: 1.2),
          ),
        );
      },
    );
  }

  pw.Widget _decoratedPage({
    required _PdfBookStyle style,
    required pw.Widget child,
  }) {
    return pw.Stack(
      children: [
        ..._buildDecorations(style),
        pw.Positioned.fill(
          child: pw.Padding(padding: const pw.EdgeInsets.all(20), child: child),
        ),
      ],
    );
  }

  List<pw.Widget> _buildDecorations(_PdfBookStyle style) {
    return [
      _flower(left: 20, top: 22, style: style, scale: 1.05),
      _flower(right: 24, top: 42, style: style, scale: 0.78),
      _leaf(left: 42, bottom: 36, style: style, angle: 0.5),
      _leaf(right: 42, bottom: 32, style: style, angle: -0.5),
      _dot(left: 92, top: 74, color: style.softBlue),
      _dot(right: 98, bottom: 86, color: style.softPink),
    ];
  }

  pw.Widget _flower({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required _PdfBookStyle style,
    required double scale,
  }) {
    final petal = 13.0 * scale;
    final center = 11.0 * scale;
    final size = 46.0 * scale;
    return pw.Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: pw.SizedBox(
        width: size,
        height: size,
        child: pw.Stack(
          children: [
            pw.Positioned(
              left: size / 2 - petal / 2,
              top: 0,
              child: _circle(petal, style.softPink),
            ),
            pw.Positioned(
              left: size / 2 - petal / 2,
              bottom: 0,
              child: _circle(petal, style.softPink),
            ),
            pw.Positioned(
              left: 0,
              top: size / 2 - petal / 2,
              child: _circle(petal, style.softPink),
            ),
            pw.Positioned(
              right: 0,
              top: size / 2 - petal / 2,
              child: _circle(petal, style.softPink),
            ),
            pw.Positioned(
              left: size / 2 - center / 2,
              top: size / 2 - center / 2,
              child: _circle(center, style.accentLight),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _leaf({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required _PdfBookStyle style,
    required double angle,
  }) {
    return pw.Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: pw.Transform.rotate(
        angle: angle,
        child: pw.Container(
          width: 44,
          height: 20,
          decoration: pw.BoxDecoration(
            color: style.softGreen,
            borderRadius: pw.BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  pw.Widget _dot({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required PdfColor color,
  }) {
    return pw.Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: _circle(10, color),
    );
  }

  pw.Widget _circle(double size, PdfColor color) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
    );
  }

  pw.Widget _miniFlowerRow(_PdfBookStyle style) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        _tinyFlower(style),
        pw.SizedBox(width: 16),
        _tinyFlower(style),
        pw.SizedBox(width: 16),
        _tinyFlower(style),
      ],
    );
  }

  pw.Widget _tinyFlower(_PdfBookStyle style) {
    return pw.SizedBox(
      width: 24,
      height: 24,
      child: pw.Stack(
        children: [
          pw.Positioned(left: 9, top: 0, child: _circle(7, style.softPink)),
          pw.Positioned(left: 9, bottom: 0, child: _circle(7, style.softPink)),
          pw.Positioned(left: 0, top: 9, child: _circle(7, style.softPink)),
          pw.Positioned(right: 0, top: 9, child: _circle(7, style.softPink)),
          pw.Positioned(left: 8, top: 8, child: _circle(8, style.accentLight)),
        ],
      ),
    );
  }

  pw.Widget _miniLeafLine(_PdfBookStyle style) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        _smallLeaf(style),
        pw.SizedBox(width: 10),
        _smallLeaf(style),
        pw.SizedBox(width: 10),
        _smallLeaf(style),
      ],
    );
  }

  pw.Widget _smallLeaf(_PdfBookStyle style) {
    return pw.Container(
      width: 32,
      height: 12,
      decoration: pw.BoxDecoration(
        color: style.softGreen,
        borderRadius: pw.BorderRadius.circular(12),
      ),
    );
  }

  pw.Widget _sectionTitle(String text, _PdfBookStyle style) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: style.sectionTitleSize,
        fontWeight: pw.FontWeight.bold,
        color: style.titleColor,
      ),
    );
  }

  pw.Widget _summaryCard({
    required _SummaryItem item,
    required _PdfBookStyle style,
  }) {
    return pw.Container(
      width: 236,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: style.cardBackground,
        borderRadius: pw.BorderRadius.circular(style.radius),
        border: pw.Border.all(color: style.accentLight, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 42,
            height: 42,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: style.iconBackground,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Text(
              item.marker,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: style.titleColor,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.label,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: style.textSoft,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  item.value,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: style.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _entryCard({
    required JournalEntry entry,
    required _PdfBookStyle style,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: pw.EdgeInsets.all(style.entryPadding),
      decoration: pw.BoxDecoration(
        color: style.entryBackground,
        borderRadius: pw.BorderRadius.circular(style.entryRadius),
        border: pw.Border.all(color: style.accentLight, width: 0.9),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _formatDateTime(entry.createdAt),
            style: pw.TextStyle(fontSize: 10.5, color: style.textSoft),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            _entryTitle(entry),
            style: pw.TextStyle(
              fontSize: style.entryTitleSize,
              fontWeight: pw.FontWeight.bold,
              color: style.titleColor,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Duygu: ${entry.moodLabel}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: style.accentDark,
            ),
          ),
          if (entry.promptText != null &&
              entry.promptText!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Konu: ${entry.promptText}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: style.textSoft,
              ),
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Text(
            entry.text,
            style: pw.TextStyle(
              fontSize: style.bodySize,
              color: style.textColor,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  String _entryTitle(JournalEntry entry) {
    final title = entry.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return 'Günlük Yazım';
  }

  String _formatNullableDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Henüz yok';
    }
    return _formatDate(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    return '$day.$month.${localDate.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '${_formatDate(localDate)} $hour:$minute';
  }

  String _stripEmojiPrefix(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Henüz yok';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return trimmed;
    }
    final first = parts.first;
    final hasAsciiLetterOrDigit = RegExp(r'[A-Za-z0-9]').hasMatch(first);
    return hasAsciiLetterOrDigit ? trimmed : parts.sublist(1).join(' ');
  }

  String safeFileName({required String childName}) {
    final ascii = _turkishToAscii(childName.toLowerCase());
    final normalized = ascii
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final suffix = normalized.isEmpty ? 'yazar' : normalized;
    return 'eglenceli_gunluk_$suffix.pdf';
  }

  String _turkishToAscii(String value) {
    const replacements = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'İ': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
    };

    var result = value;
    for (final replacement in replacements.entries) {
      result = result.replaceAll(replacement.key, replacement.value);
    }
    return result;
  }
}

class _PdfFonts {
  const _PdfFonts({
    required this.regular,
    required this.bold,
    required this.italic,
  });

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
}

class _PdfBookStyle {
  const _PdfBookStyle({
    required this.pageBackground,
    required this.frameColor,
    required this.cardBackground,
    required this.entryBackground,
    required this.noteBackground,
    required this.iconBackground,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.titleColor,
    required this.textColor,
    required this.textSoft,
    required this.softPink,
    required this.softBlue,
    required this.softGreen,
    required this.coverTitleSize,
    required this.sectionTitleSize,
    required this.subtitleSize,
    required this.bodySize,
    required this.entryTitleSize,
    required this.radius,
    required this.largeRadius,
    required this.entryRadius,
    required this.entryPadding,
  });

  final PdfColor pageBackground;
  final PdfColor frameColor;
  final PdfColor cardBackground;
  final PdfColor entryBackground;
  final PdfColor noteBackground;
  final PdfColor iconBackground;
  final PdfColor accent;
  final PdfColor accentLight;
  final PdfColor accentDark;
  final PdfColor titleColor;
  final PdfColor textColor;
  final PdfColor textSoft;
  final PdfColor softPink;
  final PdfColor softBlue;
  final PdfColor softGreen;
  final double coverTitleSize;
  final double sectionTitleSize;
  final double subtitleSize;
  final double bodySize;
  final double entryTitleSize;
  final double radius;
  final double largeRadius;
  final double entryRadius;
  final double entryPadding;

  factory _PdfBookStyle.forAgeGroup(AgeGroup ageGroup) {
    return switch (ageGroup) {
      AgeGroup.sixToEight => _PdfBookStyle.young(),
      AgeGroup.nineToEleven => _PdfBookStyle.older(),
    };
  }

  factory _PdfBookStyle.young() {
    return const _PdfBookStyle(
      pageBackground: PdfColor.fromInt(0xFFFFF8E8),
      frameColor: PdfColor.fromInt(0xFFFFD966),
      cardBackground: PdfColor.fromInt(0xFFFFFFFF),
      entryBackground: PdfColor.fromInt(0xFFFFF2CC),
      noteBackground: PdfColor.fromInt(0xFFFFF7D1),
      iconBackground: PdfColor.fromInt(0xFFFFD966),
      accent: PdfColor.fromInt(0xFFFFB56B),
      accentLight: PdfColor.fromInt(0xFFFFD966),
      accentDark: PdfColor.fromInt(0xFFB96B2B),
      titleColor: PdfColor.fromInt(0xFF5A4632),
      textColor: PdfColor.fromInt(0xFF5A4632),
      textSoft: PdfColor.fromInt(0xFF7A6247),
      softPink: PdfColor.fromInt(0xFFFFC7D9),
      softBlue: PdfColor.fromInt(0xFFBDE4FF),
      softGreen: PdfColor.fromInt(0xFFCDECCB),
      coverTitleSize: 36,
      sectionTitleSize: 25,
      subtitleSize: 18,
      bodySize: 13.5,
      entryTitleSize: 18,
      radius: 16,
      largeRadius: 24,
      entryRadius: 18,
      entryPadding: 17,
    );
  }

  factory _PdfBookStyle.older() {
    return const _PdfBookStyle(
      pageBackground: PdfColor.fromInt(0xFFFFF9EE),
      frameColor: PdfColor.fromInt(0xFFD8C7F2),
      cardBackground: PdfColor.fromInt(0xFFFFFFFF),
      entryBackground: PdfColor.fromInt(0xFFF8F2FF),
      noteBackground: PdfColor.fromInt(0xFFF4F8EA),
      iconBackground: PdfColor.fromInt(0xFFE6D9FA),
      accent: PdfColor.fromInt(0xFFFFB56B),
      accentLight: PdfColor.fromInt(0xFFD8C7F2),
      accentDark: PdfColor.fromInt(0xFF6A568A),
      titleColor: PdfColor.fromInt(0xFF4F3D63),
      textColor: PdfColor.fromInt(0xFF4C4638),
      textSoft: PdfColor.fromInt(0xFF6D6657),
      softPink: PdfColor.fromInt(0xFFF3D4E4),
      softBlue: PdfColor.fromInt(0xFFD7E9F7),
      softGreen: PdfColor.fromInt(0xFFDCECCB),
      coverTitleSize: 32,
      sectionTitleSize: 23,
      subtitleSize: 17,
      bodySize: 12.8,
      entryTitleSize: 17,
      radius: 12,
      largeRadius: 18,
      entryRadius: 12,
      entryPadding: 15,
    );
  }
}

class _SummaryItem {
  const _SummaryItem(this.label, this.value, this.marker);

  final String label;
  final String value;
  final String marker;
}
