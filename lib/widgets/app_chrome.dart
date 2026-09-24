import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final tokens = context.tokens;

    return Material(
      color: tokens.accentBg,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('theme-toggle'),
        customBorder: const CircleBorder(),
        onTap: () => provider.toggleTheme(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Text(
              provider.isDarkMode ? '☀' : '☾',
              style: GoogleFonts.nunito(color: tokens.accent, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTopRow extends StatelessWidget {
  const AppTopRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [ThemeToggleButton()],
      ),
    );
  }
}
