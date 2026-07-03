class RewardActivityStats {
  const RewardActivityStats({
    required this.hasOpenedBook,
    required this.hasPreviewedPdf,
    required this.coachHelpCount,
  });

  const RewardActivityStats.empty()
    : hasOpenedBook = false,
      hasPreviewedPdf = false,
      coachHelpCount = 0;

  final bool hasOpenedBook;
  final bool hasPreviewedPdf;
  final int coachHelpCount;
}
