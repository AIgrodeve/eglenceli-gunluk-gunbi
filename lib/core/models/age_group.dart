enum AgeGroup {
  sixToEight('6-8 yaş'),
  nineToEleven('9-11 yaş');

  const AgeGroup(this.label);

  final String label;

  String get storageValue {
    return switch (this) {
      AgeGroup.sixToEight => '6-8',
      AgeGroup.nineToEleven => '9-11',
    };
  }

  static AgeGroup? fromStorageValue(String? value) {
    return switch (value) {
      '6-8' => AgeGroup.sixToEight,
      '9-11' => AgeGroup.nineToEleven,
      _ => null,
    };
  }
}
