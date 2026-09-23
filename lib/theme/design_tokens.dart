import 'package:flutter/material.dart';

class DesignTokens {
  final Color bg;
  final Color surface;
  final Color text;
  final Color text2;
  final Color muted;
  final Color faint;
  final Color faint2;
  final Color chevron;
  final Color chipText;
  final Color border;
  final Color inputBorder;
  final Color chipBorder;
  final Color divider;
  final Color track;
  final Color tabInactive;
  final Color tabbar;
  final Color accent;
  final Color accentBg;
  final Color accentBorder;
  final Color accentDeep;
  final Color accentSoft;
  final Color tagWarmBg;
  final Color tagWarmText;
  final Color tagMintBg;
  final Color tagMintText;
  final Color danger;

  const DesignTokens({
    required this.bg,
    required this.surface,
    required this.text,
    required this.text2,
    required this.muted,
    required this.faint,
    required this.faint2,
    required this.chevron,
    required this.chipText,
    required this.border,
    required this.inputBorder,
    required this.chipBorder,
    required this.divider,
    required this.track,
    required this.tabInactive,
    required this.tabbar,
    required this.accent,
    required this.accentBg,
    required this.accentBorder,
    required this.accentDeep,
    required this.accentSoft,
    required this.tagWarmBg,
    required this.tagWarmText,
    required this.tagMintBg,
    required this.tagMintText,
    required this.danger,
  });

  static const light = DesignTokens(
    bg: Color(0xFFFFFBF3),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF2B2622),
    text2: Color(0xFF4A443C),
    muted: Color(0xFF9A8F84),
    faint: Color(0xFFBAAE9F),
    faint2: Color(0xFFCFC4B4),
    chevron: Color(0xFFD8CDBF),
    chipText: Color(0xFF6B5F52),
    border: Color(0xFFF2EADF),
    inputBorder: Color(0xFFF0E7DA),
    chipBorder: Color(0xFFEFE5D7),
    divider: Color(0xFFF6EFE4),
    track: Color(0xFFF3EADD),
    tabInactive: Color(0xFFB4A99C),
    tabbar: Color(0xF0FFFBF3),
    accent: Color(0xFFFF6B4A),
    accentBg: Color(0xFFFFEEE8),
    accentBorder: Color(0xFFFFD9CC),
    accentDeep: Color(0xFFC4593C),
    accentSoft: Color(0xFFFFF6F2),
    tagWarmBg: Color(0xFFFFF1D9),
    tagWarmText: Color(0xFF9A6B00),
    tagMintBg: Color(0xFFD6F5EA),
    tagMintText: Color(0xFF0B7A56),
    danger: Color(0xFFD9534F),
  );

  static const dark = DesignTokens(
    bg: Color(0xFF1B1712),
    surface: Color(0xFF251F19),
    text: Color(0xFFF4EEE4),
    text2: Color(0xFFD6CDC0),
    muted: Color(0xFFA99C8C),
    faint: Color(0xFF8A7D6E),
    faint2: Color(0xFF6E6355),
    chevron: Color(0xFF5A5044),
    chipText: Color(0xFFC9BDAD),
    border: Color(0xFF342A20),
    inputBorder: Color(0xFF3A2F23),
    chipBorder: Color(0xFF382D22),
    divider: Color(0xFF2C231B),
    track: Color(0xFF342A20),
    tabInactive: Color(0xFF8A7D6E),
    tabbar: Color(0xF01B1712),
    accent: Color(0xFFFF6B4A),
    accentBg: Color(0x29FF6B4A),
    accentBorder: Color(0x52FF6B4A),
    accentDeep: Color(0xFFFF9070),
    accentSoft: Color(0x1AFF6B4A),
    tagWarmBg: Color(0x26F5B700),
    tagWarmText: Color(0xFFF0C24A),
    tagMintBg: Color(0x2612B981),
    tagMintText: Color(0xFF43CE9E),
    danger: Color(0xFFFF7B76),
  );
}

extension DesignTokensContext on BuildContext {
  DesignTokens get tokens => Theme.of(this).brightness == Brightness.dark
      ? DesignTokens.dark
      : DesignTokens.light;
}
