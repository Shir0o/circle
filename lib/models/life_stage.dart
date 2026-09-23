import 'package:flutter/material.dart';

enum LifeStage {
  kids(
    serialized: 'child',
    label: 'Kids',
    bg: Color(0xFFFEF1CF),
    color: Color(0xFFB27A00),
    avatarBg: Color(0xFFF5B700),
    avatarColor: Color(0xFF3A2C00),
  ),
  teens(
    serialized: 'teen',
    label: 'Teens',
    bg: Color(0xFFFFE0EC),
    color: Color(0xFFC13567),
    avatarBg: Color(0xFFFF5D8F),
    avatarColor: Color(0xFF4A0A22),
  ),
  college(
    serialized: 'college',
    label: 'College',
    bg: Color(0xFFECE6FF),
    color: Color(0xFF5B3EDA),
    avatarBg: Color(0xFF7C5CFC),
    avatarColor: Color(0xFF1E1147),
  ),
  working(
    serialized: 'working',
    label: 'Working',
    bg: Color(0xFFD6F5EA),
    color: Color(0xFF0B7A56),
    avatarBg: Color(0xFF12B981),
    avatarColor: Color(0xFF04331F),
  );

  const LifeStage({
    required this.serialized,
    required this.label,
    required this.bg,
    required this.color,
    required this.avatarBg,
    required this.avatarColor,
  });

  final String serialized;
  final String label;
  final Color bg;
  final Color color;
  final Color avatarBg;
  final Color avatarColor;

  static LifeStage fromStorage(String? value) {
    for (final stage in values) {
      if (stage.serialized == value) return stage;
    }
    return LifeStage.college;
  }
}
