enum LifeStage {
  kids(serialized: 'child', label: 'Kids'),
  teens(serialized: 'teen', label: 'Teens'),
  college(serialized: 'college', label: 'College'),
  working(serialized: 'working', label: 'Working');

  const LifeStage({required this.serialized, required this.label});

  final String serialized;
  final String label;

  static LifeStage fromStorage(String? value) {
    for (final stage in values) {
      if (stage.serialized == value) return stage;
    }
    return LifeStage.college;
  }
}
