class GunbiGrowth {
  const GunbiGrowth({required this.title, required this.description});

  final String title;
  final String description;

  factory GunbiGrowth.fromEntryCount(int entryCount) {
    if (entryCount == 0) {
      return const GunbiGrowth(
        title: 'Günbi seni bekliyor',
        description: 'Günbi ilk yazını bekliyor.',
      );
    }
    if (entryCount < 10) {
      return const GunbiGrowth(
        title: 'Günbi uyandı',
        description: 'Günbi seninle yazı yolculuğuna başladı.',
      );
    }
    if (entryCount < 25) {
      return const GunbiGrowth(
        title: 'Günbi parlıyor',
        description: 'Günbi parlıyor! Yazıların çoğalıyor.',
      );
    }
    if (entryCount < 50) {
      return const GunbiGrowth(
        title: 'Günbi aksesuar kazandı',
        description: 'Günbi seninle gurur duyuyor.',
      );
    }

    return const GunbiGrowth(
      title: 'Günbi özel formda',
      description: 'Günbi özel formunda! Harika bir yazı yolculuğu!',
    );
  }
}
