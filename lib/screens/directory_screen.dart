import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/life_stage.dart';
import '../models/month_names.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';

class DirectoryScreen extends StatelessWidget {
  final ValueChanged<int>? onSwitchTab;

  const DirectoryScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final people = provider.filteredPeople;
    final counts = provider.stageCounts;
    final activeFilter = provider.stageFilter;

    final filterDefs = [
      {'key': 'all', 'label': 'All'},
      {'key': 'child', 'label': 'Kids'},
      {'key': 'teen', 'label': 'Teens'},
      {'key': 'college', 'label': 'College'},
      {'key': 'working', 'label': 'Working'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => provider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: Icon(Icons.search_rounded, color: tokens.muted),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: filterDefs.map((def) {
                  final key = def['key'] as String;
                  final label = def['label'] as String;
                  final count = counts[key] ?? 0;
                  final isActive = activeFilter == key;

                  Color chipBg;
                  Color chipText;
                  Color chipBorder;

                  if (isActive) {
                    if (key == 'all') {
                      chipBg = theme.colorScheme.primary;
                    } else {
                      chipBg = LifeStage.fromStorage(key).avatarBg;
                    }
                    chipText = Colors.white;
                    chipBorder = chipBg;
                  } else {
                    chipBg = theme.cardTheme.color ?? theme.colorScheme.surface;
                    chipText = tokens.chipText;
                    chipBorder = tokens.chipBorder;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => provider.setStageFilter(key),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: chipBorder, width: 1),
                        ),
                        child: Row(
                          children: [
                            if (!isActive && key != 'all') ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: LifeStage.fromStorage(key).avatarBg,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '$label $count',
                              style: TextStyle(
                                color: chipText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Next Birthday Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tokens.accentBorder),
                ),
                child: Row(
                  children: [
                    const Text('🎂', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Next: ${provider.nextBirthdayBannerText}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // People List
            Expanded(
              child: people.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: tokens.faint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No people found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: tokens.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: people.length,
                      itemBuilder: (context, index) {
                        final person = people[index];
                        final meta = person.stage;
                        final bdayStr =
                            '${monthNames[person.bMonth - 1]} ${person.bDay}';
                        final metaLine = [
                          if (person.location.isNotEmpty) person.location,
                          bdayStr,
                        ].join(' · ');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
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
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Avatar
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
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                person.name,
                                                style:
                                                    theme.textTheme.titleMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: meta.bg,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                meta.label,
                                                style: TextStyle(
                                                  color: meta.color,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        if (person
                                            .subLine(
                                              referenceDate: provider.today,
                                            )
                                            .isNotEmpty)
                                          Text(
                                            person.subLine(
                                              referenceDate: provider.today,
                                            ),
                                            style: theme.textTheme.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (metaLine.isNotEmpty)
                                          Text(
                                            metaLine,
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: tokens.chevron,
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
