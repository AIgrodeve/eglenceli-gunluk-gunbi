import 'package:flutter/material.dart';

import '../../core/data/app_reset_service.dart';
import '../../core/data/app_preferences.dart';
import '../../core/models/age_group.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mascot_widget.dart';
import '../journal/data/journal_repository.dart';
import '../onboarding/onboarding_flow.dart';
import '../parent/parent_page.dart';
import '../parent/services/parent_pin_service.dart';
import '../privacy/privacy_policy_page.dart';
import 'about_page.dart';

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
  final AppResetService _resetService = const AppResetService();
  final ParentPinService _parentPinService = const ParentPinService();
  late final TextEditingController _nameController;
  late AgeGroup _selectedAgeGroup;
  late Future<int> _entryCountFuture;
  bool _isResetting = false;

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
          content: Text(
            "GÃ¼nbi seni nasÄ±l Ã§aÄŸÄ±racaÄŸÄ±nÄ± bilmek istiyor.",
          ),
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
    ).showSnackBar(const SnackBar(content: Text('AdÄ±n kaydedildi.')));
  }

  Future<void> _selectAgeGroup(AgeGroup ageGroup) async {
    setState(() => _selectedAgeGroup = ageGroup);
    await _preferences.updateChildAgeGroup(ageGroup);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('YaÅŸ grubu gÃ¼ncellendi.')));
  }

  Future<void> _startDeleteAllDataFlow() async {
    final verified = await _showParentPinDialog();
    if (!verified || !mounted) {
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isResetting = true);

    try {
      await _resetService.clearAllLocalData();
    } catch (error, stackTrace) {
      debugPrint('App reset failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() => _isResetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veriler silinirken bir sorun oluÅŸtu. LÃ¼tfen tekrar deneyin.',
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingFlow(
          initialMessage: 'Veriler bu cihazdan silindi.',
        ),
      ),
      (_) => false,
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tüm veriler silinsin mi?'),
          content: const SingleChildScrollView(
            child: Text(
              'Bu iÅŸlem gÃ¼nlÃ¼k yazÄ±larÄ±nÄ±, rozet ilerlemesini, seri bilgilerini, kitap baÅŸlÄ±ÄŸÄ±nÄ± ve profil bilgilerini bu cihazdan siler. Bu iÅŸlem geri alÄ±namaz.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('VazgeÃ§'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE78A7A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Evet, sil'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showParentPinDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ParentPinDialog(parentPinService: _parentPinService),
    );

    return result ?? false;
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
                      decoration: const InputDecoration(
                        labelText: 'Ã‡ocuk adÄ±',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saveName,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('AdÄ±mÄ± kaydet'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'YaÅŸ grubu',
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
                    title: 'Uygulama Ã¶zeti',
                    child: Column(
                      children: [
                        _InfoRow(label: 'Ã‡ocuk adÄ±', value: _displayName),
                        _InfoRow(
                          label: 'YaÅŸ grubu',
                          value: _selectedAgeGroup.label,
                        ),
                        _InfoRow(label: 'Toplam yazÄ±', value: '$totalEntries'),
                        const _InfoRow(
                          label: 'Uygulama adÄ±',
                          value: 'EÄŸlenceli GÃ¼nlÃ¼k',
                        ),
                        const _InfoRow(label: 'Maskot', value: 'GÃ¼nbi'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Uygulama Bilgisi',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'EÄŸlenceli GÃ¼nlÃ¼k, Ã§ocuklarÄ±n yazma alÄ±ÅŸkanlÄ±ÄŸÄ± kazanmasÄ±na yardÄ±mcÄ± olmak iÃ§in tasarlanmÄ±ÅŸtÄ±r.',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('HakkÄ±nda'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Gizlilik ve GÃ¼venlik',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PrivacyBullet('Günlük kayıtları cihazda saklanır.'),
                    const _PrivacyBullet(
                      'Gelişmiş yazı kontrolü açılırsa başlık ve yazı yalnızca öneri üretmek için güvenli API servisine gönderilebilir.',
                    ),
                    const _PrivacyBullet('Herkese aÃ§Ä±k paylaÅŸÄ±m yoktur.'),
                    const _PrivacyBullet(
                      'Ã‡ocuklar arasÄ± mesajlaÅŸma yoktur.',
                    ),
                    const _PrivacyBullet('Konum izni kullanÄ±lmaz.'),
                    const _PrivacyBullet('Reklam gÃ¶sterilmez.'),
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
                      label: const Text('Gizlilik PolitikasÄ±'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Premium',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Premium Ã¶zellikler Ebeveyn AlanÄ± Ã¼zerinden yÃ¶netilir.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ParentPage(
                              childName: _displayName,
                              ageGroup: _selectedAgeGroup,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.family_restroom_rounded),
                      label: const Text('Ebeveyn AlanÄ±na Git'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Verilerim',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'GÃ¼nlÃ¼k yazÄ±larÄ±n ve uygulama bilgilerin bu cihazda saklanÄ±r.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB94A3D),
                        side: const BorderSide(color: Color(0xFFE9A49A)),
                        backgroundColor: const Color(0xFFFFF1EF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _isResetting ? null : _startDeleteAllDataFlow,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        _isResetting
                            ? 'Veriler siliniyor...'
                            : 'TÃ¼m verileri sil',
                      ),
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

class _ParentPinDialog extends StatefulWidget {
  const _ParentPinDialog({required this.parentPinService});

  final ParentPinService parentPinService;

  @override
  State<_ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends State<_ParentPinDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isChecking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
      _errorText = null;
    });

    final verified = await widget.parentPinService.verifyPin(_controller.text);
    if (!mounted) {
      return;
    }

    if (verified) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isChecking = false;
      _errorText = 'Åifre hatalÄ±. LÃ¼tfen tekrar deneyin.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ebeveyn doÄŸrulamasÄ±'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bu iÅŸlem ebeveynler iÃ§indir. Devam etmek iÃ§in ebeveyn ÅŸifresini girin.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: !_isChecking,
              decoration: InputDecoration(
                labelText: 'Åifre',
                errorText: _errorText,
              ),
              onSubmitted: (_) => _verify(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isChecking
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('VazgeÃ§'),
        ),
        FilledButton(
          onPressed: _isChecking ? null : _verify,
          child: Text(_isChecking ? 'Kontrol ediliyor...' : 'Devam et'),
        ),
      ],
    );
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
    final valueStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: valueStyle,
                ),
              ),
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
          const Text('â€¢ '),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
