import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/month_names.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';

class BirthdaysScreen extends StatelessWidget {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final upcomingList = provider.upcomingBirthdays;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Birthdays', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Upcoming celebrations across your circle',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: upcomingList.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming birthdays',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: upcomingList.length,
                      itemBuilder: (context, index) {
                        final entry = upcomingList[index];
                        final person = entry.key;
                        final days = entry.value;

                        final meta = person.stage;
                        final turns = person.turnsAge(
                          referenceDate: provider.today,
                        );
                        final isSoon = days <= 30;

                        final dateLine =
                            '${monthNames[person.bMonth - 1]} ${person.bDay}${turns != null ? ' · turns $turns' : ''}';

                        Color cardBg;
                        Color cardBorder;
                        if (isSoon) {
                          cardBg = tokens.accentSoft;
                          cardBorder = tokens.accentBorder;
                        } else {
                          cardBg =
                              theme.cardTheme.color ??
                              theme.colorScheme.surface;
                          cardBorder = tokens.border;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder, width: 1),
                          ),
                          child: InkWell(
                            onTap: () {
                              provider.selectPerson(person);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(person: person),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: meta.avatarBg,
                                    child: Text(
                                      person.initials,
                                      style: TextStyle(
                                        color: meta.avatarColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          person.name,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateLine,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Days Counter Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSoon
                                          ? theme.colorScheme.primary
                                          : tokens.divider,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          days == 0 ? '🎉' : '$days',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: isSoon
                                                ? Colors.white
                                                : tokens.text,
                                          ),
                                        ),
                                        Text(
                                          days == 0
                                              ? 'today'
                                              : (days == 1 ? 'day' : 'days'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isSoon
                                                ? Colors.white.withValues(
                                                    alpha: 0.9,
                                                  )
                                                : tokens.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
