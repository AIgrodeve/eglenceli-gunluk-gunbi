import 'package:flutter/material.dart';

import '../../core/data/app_preferences.dart';
import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../privacy/privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.childName,
    required this.ageGroup,
  });

  final String childName;
  final AgeGroup ageGroup;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppPreferences _preferences = const AppPreferences();
  final JournalRepository _repository = const JournalRepository();
  late final TextEditingController _nameController;
  late AgeGroup _selectedAgeGroup;
  late Future<int> _entryCountFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.childName);
    _selectedAgeGroup = widget.ageGroup;
    _entryCountFuture = _loadEntryCount();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<int> _loadEntryCount() async {
    final entries = await _repository.loadEntries();
    return entries.length;
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Günbi seni nasıl çağıracağını bilmek istiyor."),
        ),
      );
      return;
    }

    await _preferences.updateChildName(name);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Adın kaydedildi.')));
  }

  Future<void> _selectAgeGroup(AgeGroup ageGroup) async {
    setState(() => _selectedAgeGroup = ageGroup);
    await _preferences.updateChildAgeGroup(ageGroup);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yaş grubu güncellendi.')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(
          SettingsResult(
            childName: _nameController.text.trim().isEmpty
                ? widget.childName
                : _nameController.text.trim(),
            ageGroup: _selectedAgeGroup,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ayarlar'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(
                SettingsResult(
                  childName: _nameController.text.trim().isEmpty
                      ? widget.childName
                      : _nameController.text.trim(),
                  ageGroup: _selectedAgeGroup,
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(
                child: MascotWidget(
                  size: 96,
                  mood: MascotMood.calm,
                  showShadow: false,
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Profil',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Çocuk adı'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saveName,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Adımı kaydet'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Yaş grubu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    for (final ageGroup in AgeGroup.values) ...[
                      _AgeGroupTile(
                        ageGroup: ageGroup,
                        isSelected: _selectedAgeGroup == ageGroup,
                        onTap: () => _selectAgeGroup(ageGroup),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<int>(
                future: _entryCountFuture,
                builder: (context, snapshot) {
                  final totalEntries = snapshot.data ?? 0;

                  return _SectionCard(
                    title: 'Uygulama özeti',
                    child: Column(
                      children: [
                        _InfoRow(label: 'Çocuk adı', value: _displayName),
                        _InfoRow(
                          label: 'Yaş grubu',
                          value: _selectedAgeGroup.label,
                        ),
                        _InfoRow(label: 'Toplam yazı', value: '$totalEntries'),
                        const _InfoRow(
                          label: 'Uygulama adı',
                          value: 'Eğlenceli Günlük',
                        ),
                        const _InfoRow(label: 'Maskot', value: 'Günbi'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              const _SectionCard(
                title: 'Uygulama Bilgisi',
                child: Text(
                  'Eğlenceli Günlük, çocukların yazma alışkanlığı kazanmasına yardımcı olmak için tasarlanmıştır.',
                ),
              ),
              const SizedBox(height: 14),
              const _SectionCard(
                title: 'Gizlilik Notu',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrivacyBullet('Günlük yazıları bu cihazda saklanır.'),
                    _PrivacyBullet('Herkese açık paylaşım yoktur.'),
                    _PrivacyBullet('Çocuklar arası mesajlaşma yoktur.'),
                    _PrivacyBullet('Konum izni kullanılmaz.'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Gizlilik ve Güvenlik',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PrivacyBullet(
                      'Günlük yazıları bu cihazda saklanır.',
                    ),
                    const _PrivacyBullet('Herkese açık paylaşım yoktur.'),
                    const _PrivacyBullet('Çocuklar arası mesajlaşma yoktur.'),
                    const _PrivacyBullet('Konum izni kullanılmaz.'),
                    const _PrivacyBullet('Reklam gösterilmez.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.privacy_tip_rounded),
                      label: const Text('Gizlilik Politikası'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _displayName {
    final name = _nameController.text.trim();
    return name.isEmpty ? widget.childName : name;
  }
}

class SettingsResult {
  const SettingsResult({required this.childName, required this.ageGroup});

  final String childName;
  final AgeGroup ageGroup;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.pastelYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AgeGroupTile extends StatelessWidget {
  const _AgeGroupTile({
    required this.ageGroup,
    required this.isSelected,
    required this.onTap,
  });

  final AgeGroup ageGroup;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.pastelYellow : AppTheme.cream,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ageGroup.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  const _PrivacyBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
