class GunbiGrowth {
  const GunbiGrowth({required this.title, required this.description});

  final String title;
  final String description;

  factory GunbiGrowth.fromEntryCount(int entryCount) {
    if (entryCount == 0) {
      return const GunbiGrowth(
        title: 'Günbi seni bekliyor',
        description: 'İlk yazını yazınca Günbi de yolculuğa başlayacak.',
      );
    }
    if (entryCount < 10) {
      return GunbiGrowth(
        title: 'Günbi uyandı',
        description:
            'Sen $entryCount yazı yazdın. Günbi seninle büyümeye başladı!',
      );
    }
    if (entryCount < 25) {
      return GunbiGrowth(
        title: 'Günbi parlıyor',
        description:
            'Sen $entryCount yazı yazdın. Günbi artık ışıl ışıl görünüyor!',
      );
    }
    if (entryCount < 50) {
      return GunbiGrowth(
        title: 'Günbi aksesuar kazandı',
        description:
            'Sen $entryCount yazı yazdın. Günbi yeni bir sürpriz kazandı!',
      );
    }

    return GunbiGrowth(
      title: 'Günbi özel formda',
      description: 'Sen $entryCount yazı yazdın. Günbi özel formuyla yanında!',
    );
  }
}
