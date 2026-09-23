import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/life_stage.dart';
import '../models/month_names.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_chrome.dart';
import 'form_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Person person;

  const ProfileScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final theme = Theme.of(context);

    // Refresh person from provider state in case it was edited
    final currentPerson = provider.people.firstWhere(
      (p) => p.id == person.id,
      orElse: () => person,
    );

    final tokens = context.tokens;
    final meta = currentPerson.stage;

    final age = currentPerson.getAge(referenceDate: provider.today);
    final bdayStr =
        '${monthNames[currentPerson.bMonth - 1]} ${currentPerson.bDay}${currentPerson.bYear != null ? ', ${currentPerson.bYear}' : ''}';

    final infoRows = <Map<String, String>>[];
    if (currentPerson.stage == LifeStage.college) {
      if (currentPerson.year.isNotEmpty) {
        infoRows.add({'label': 'Year', 'value': currentPerson.year});
      }
      if (currentPerson.major.isNotEmpty) {
        infoRows.add({'label': 'Major', 'value': currentPerson.major});
      }
      if (currentPerson.school.isNotEmpty) {
        infoRows.add({'label': 'College', 'value': currentPerson.school});
      }
    } else if (currentPerson.stage == LifeStage.teens ||
        currentPerson.stage == LifeStage.kids) {
      if (currentPerson.grade.isNotEmpty) {
        infoRows.add({'label': 'Grade', 'value': currentPerson.grade});
      }
      if (currentPerson.school.isNotEmpty) {
        infoRows.add({'label': 'School', 'value': currentPerson.school});
      }
    } else {
      if (currentPerson.occupation.isNotEmpty) {
        infoRows.add({
          'label': 'Occupation',
          'value': currentPerson.occupation,
        });
      }
    }

    infoRows.add({'label': 'Birthday', 'value': bdayStr});
    if (currentPerson.location.isNotEmpty) {
      infoRows.add({'label': 'Location', 'value': currentPerson.location});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormScreen(person: currentPerson),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: meta.avatarBg,
                    child: Text(
                      currentPerson.initials,
                      style: TextStyle(
                        color: meta.avatarColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentPerson.name,
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meta.label,
                          style: TextStyle(
                            color: meta.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (age != null) ...[
                        const SizedBox(width: 8),
                        Text('$age yrs', style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                  if (currentPerson.howKnow.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Connection: ${currentPerson.howKnow}',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: infoRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(row['label']!, style: theme.textTheme.bodySmall),
                          Text(row['value']!, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Interests Section
            if (currentPerson.interests.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Interests', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentPerson.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.tagWarmBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.tagWarmText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Dietary Section
            if (currentPerson.dietary.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Dietary Preferences', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentPerson.dietary.map((pref) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.tagMintBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      pref,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.tagMintText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Notes Section
            if (currentPerson.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Notes', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentPerson.notes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
