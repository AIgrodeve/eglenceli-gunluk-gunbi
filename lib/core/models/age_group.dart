enum AgeGroup {
  sixToEight('6-8 yaş'),
  nineToTwelve('9-12 yaş');

  const AgeGroup(this.label);

  final String label;

  String get storageValue {
    return switch (this) {
      AgeGroup.sixToEight => '6-8',
      AgeGroup.nineToTwelve => '9-12',
    };
  }

  static AgeGroup? fromStorageValue(String? value) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return switch (normalizedValue) {
      '6-8' => AgeGroup.sixToEight,
      '9-11' || '9-12' => AgeGroup.nineToTwelve,
      '13-15' || '16-17' || '16+' || '18+' => AgeGroup.nineToTwelve,
      _ => AgeGroup.nineToTwelve,
    };
  }
}
