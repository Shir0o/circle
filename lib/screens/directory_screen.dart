import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/life_stage.dart';
import '../models/month_names.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';

class DirectoryScreen extends StatelessWidget {
  final ValueChanged<int>? onSwitchTab;
  final VoidCallback? onOpenAdd;

  const DirectoryScreen({super.key, this.onSwitchTab, this.onOpenAdd});

  static const _filterDefs = [
    ('all', 'All'),
    ('child', 'Kids'),
    ('teen', 'Teens'),
    ('college', 'College'),
    ('working', 'Working'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final tokens = context.tokens;
    final people = provider.filteredPeople;
    final total = provider.people.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title, count line and round add button.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Circle',
                          style: GoogleFonts.nunito(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.54,
                            color: tokens.text,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${people.length} of $total people',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: tokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.accent,
                      boxShadow: [
                        BoxShadow(
                          color: tokens.accent.withValues(alpha: 0.7),
                          blurRadius: 18,
                          spreadRadius: -6,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        key: const Key('add-person-button'),
                        customBorder: const CircleBorder(),
                        onTap: onOpenAdd,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Text(
                              '+',
                              style: GoogleFonts.nunito(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Next-birthday hint, tappable to jump to the Birthdays tab.
            InkWell(
              key: const Key('next-birthday-hint'),
              onTap: onSwitchTab == null ? null : () => onSwitchTab!(1),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        provider.nextBirthdayBannerText,
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: tokens.muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search field: no icon, no clear button.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 2, 22, 10),
              child: TextField(
                onChanged: (val) => provider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search people',
                  filled: true,
                  fillColor: tokens.surface,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  hintStyle: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.faint2,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: tokens.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: tokens.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: tokens.accent),
                  ),
                ),
              ),
            ),

            // Filter chips.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(22, 2, 22, 12),
              child: Row(
                children: _filterDefs.map((def) {
                  final (key, label) = def;
                  return _StageChip(
                    chipKey: key,
                    label: label,
                    count: provider.stageCounts[key] ?? 0,
                    isActive: provider.stageFilter == key,
                    dotColor: key == 'all'
                        ? tokens.accent
                        : LifeStage.fromStorage(key).avatarBg,
                    fillColor: key == 'all'
                        ? tokens.accent
                        : LifeStage.fromStorage(key).avatarBg,
                    onTap: () => provider.setStageFilter(key),
                  );
                }).toList(),
              ),
            ),

            // People cards or an empty state.
            Expanded(child: _buildList(context, provider, people, tokens)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    PeopleProvider provider,
    List<Person> people,
    DesignTokens tokens,
  ) {
    final theme = Theme.of(context);

    // Render nothing until stored people have loaded, so returning users
    // never see the first-run empty state flash.
    if (!provider.isInitialized) return const SizedBox.shrink();

    if (provider.people.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 48, color: tokens.faint),
            const SizedBox(height: 12),
            Text(
              'Your circle is empty',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: tokens.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your first person to get started',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (people.isEmpty) {
      return Center(
        child: Text(
          'No one matches that yet.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: tokens.faint,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        18,
        2,
        18,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people[index];
        return _PersonCard(person: person, provider: provider);
      },
    );
  }
}

class _StageChip extends StatelessWidget {
  final String chipKey;
  final String label;
  final int count;
  final bool isActive;
  final Color dotColor;
  final Color fillColor;
  final VoidCallback onTap;

  const _StageChip({
    required this.chipKey,
    required this.label,
    required this.count,
    required this.isActive,
    required this.dotColor,
    required this.fillColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        key: Key('chip-$chipKey'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? fillColor : tokens.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? fillColor : tokens.chipBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isActive) ...[
                Container(
                  key: Key('chip-dot-$chipKey'),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : tokens.chipText,
                ),
              ),
              const SizedBox(width: 4),
              Opacity(
                opacity: 0.5,
                child: Text(
                  '$count',
                  key: Key('chip-count-$chipKey'),
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : tokens.chipText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  final PeopleProvider provider;

  const _PersonCard({required this.person, required this.provider});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final meta = person.stage;
    final sub = person.subLine(referenceDate: provider.today);
    final metaLine = [
      if (person.location.isNotEmpty) person.location,
      '${monthNames[person.bMonth - 1]} ${person.bDay}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border, width: 1),
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
                radius: 23,
                backgroundColor: meta.avatarBg,
                child: Text(
                  person.initials,
                  style: GoogleFonts.nunito(
                    color: meta.avatarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            person.name,
                            style: GoogleFonts.nunito(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: tokens.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: meta.bg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: meta.avatarBg,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                meta.label,
                                style: GoogleFonts.nunito(
                                  color: meta.color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: tokens.muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      metaLine,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: tokens.faint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '›',
                style: GoogleFonts.nunito(fontSize: 20, color: tokens.chevron),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
