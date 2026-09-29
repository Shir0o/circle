/// Formats [input] in title case: the first letter of each word is uppercased
/// and the rest lowercased, so `maya chen` becomes `Maya Chen`.
///
/// The character following an apostrophe or hyphen is also uppercased
/// (`o'brien` -> `O'Brien`, `mary-jane` -> `Mary-Jane`). Name particles are
/// not specially lowercased, so `van der berg` becomes `Van Der Berg`.
/// Whitespace is preserved exactly as typed so this can run live while the
/// user types.
String titleCase(String input) {
  final out = StringBuffer();
  var upperNext = true;
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    if (char.trim().isEmpty) {
      out.write(char);
      upperNext = true;
    } else if (char == "'" || char == '-' || char == '\u2019') {
      out.write(char);
      upperNext = true;
    } else {
      out.write(upperNext ? char.toUpperCase() : char.toLowerCase());
      upperNext = false;
    }
  }
  return out.toString();
}
