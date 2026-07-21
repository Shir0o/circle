import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import 'form_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Person person;

  const ProfileScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final theme = Theme.of(context);
    final isDark = provider.isDarkMode;

    // Refresh person from provider state in case it was edited
    final currentPerson = provider.people.firstWhere(
      (p) => p.id == person.id,
      orElse: () => person,
    );

    final meta = Person.getStageMeta(currentPerson.stage);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final age = currentPerson.getAge();
    final bdayStr = '${months[currentPerson.bMonth - 1]} ${currentPerson.bDay}${currentPerson.bYear != null ? ', ${currentPerson.bYear}' : ''}';

    final infoRows = <Map<String, String>>[];
    if (currentPerson.stage == 'college') {
      if (currentPerson.year.isNotEmpty) infoRows.add({'label': 'Year', 'value': currentPerson.year});
      if (currentPerson.major.isNotEmpty) infoRows.add({'label': 'Major', 'value': currentPerson.major});
      if (currentPerson.school.isNotEmpty) infoRows.add({'label': 'College', 'value': currentPerson.school});
    } else if (currentPerson.stage == 'teen' || currentPerson.stage == 'child') {
      if (currentPerson.grade.isNotEmpty) infoRows.add({'label': 'Grade', 'value': currentPerson.grade});
      if (currentPerson.school.isNotEmpty) infoRows.add({'label': 'School', 'value': currentPerson.school});
    } else {
      if (currentPerson.occupation.isNotEmpty) infoRows.add({'label': 'Occupation', 'value': currentPerson.occupation});
    }

    infoRows.add({'label': 'Birthday', 'value': bdayStr});
    if (currentPerson.location.isNotEmpty) {
      infoRows.add({'label': 'Location', 'value': currentPerson.location});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        Text(
                          '$age yrs',
                          style: theme.textTheme.bodyMedium,
                        ),
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
                          Text(
                            row['label']!,
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            row['value']!,
                            style: theme.textTheme.bodyLarge,
                          ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C231B) : const Color(0xFFF6EFE4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF382D22) : const Color(0xFFEFE5D7),
                      ),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFD6CDC0) : const Color(0xFF4A443C),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x26F5B700) : const Color(0xFFFFF1D9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0x52F5B700) : const Color(0xFFFFE0B2),
                      ),
                    ),
                    child: Text(
                      pref,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF0C24A) : const Color(0xFF9A6B00),
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
