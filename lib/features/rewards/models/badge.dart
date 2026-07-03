class Badge {
  const Badge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.isPremium = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool isUnlocked;
  final bool isPremium;
}
