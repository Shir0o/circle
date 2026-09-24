import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/month_names.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';

class BirthdaysScreen extends StatelessWidget {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final tokens = context.tokens;
    final entries = provider.upcomingBirthdays;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title and subtitle.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthdays',
                    key: const Key('birthdays-title'),
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.48,
                      color: tokens.text,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next up in your circle',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: tokens.muted,
                    ),
                  ),
                ],
              ),
            ),

            // Birthday rows or an empty state.
            Expanded(
              child: !provider.isInitialized
                  ? const SizedBox.shrink()
                  : entries.isEmpty
                  ? _buildEmptyState(context, tokens)
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        18,
                        2,
                        18,
                        20 + MediaQuery.paddingOf(context).bottom,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _BirthdayRow(
                          person: entry.key,
                          days: entry.value,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DesignTokens tokens) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cake_outlined, size: 48, color: tokens.faint),
          const SizedBox(height: 12),
          Text(
            'No birthdays yet',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: tokens.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add people to your circle and their birthdays will show up here',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BirthdayRow extends StatelessWidget {
  final Person person;
  final int days;

  const _BirthdayRow({required this.person, required this.days});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final tokens = context.tokens;
    final isSoon = days <= 30;
    final turns = person.turnsAge(referenceDate: provider.today);
    final dateLine =
        '${monthNames[person.bMonth - 1]} ${person.bDay}'
        '${turns != null ? ' · turns $turns' : ''}';

    return Container(
      key: Key('birthday-row-${person.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSoon ? tokens.accentSoft : tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSoon ? tokens.accentBorder : tokens.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          provider.selectPerson(person);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen(person: person)),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: person.stage.avatarBg,
                child: Text(
                  person.initials,
                  style: GoogleFonts.nunito(
                    color: person.stage.avatarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: GoogleFonts.nunito(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: tokens.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLine,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    days == 0 ? '🎉' : '$days',
                    key: Key('birthday-count-${person.id}'),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isSoon ? tokens.accent : tokens.text,
                    ),
                  ),
                  Text(
                    days == 0 ? 'today' : (days == 1 ? 'day' : 'days'),
                    key: Key('birthday-unit-${person.id}'),
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tokens.faint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
