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
    final tokens = context.tokens;

    // Refresh person from provider state in case it was edited.
    final currentPerson = provider.people.firstWhere(
      (p) => p.id == person.id,
      orElse: () => person,
    );

    final meta = currentPerson.stage;
    final age = currentPerson.getAge(referenceDate: provider.today);
    final bdayStr =
        '${monthNames[currentPerson.bMonth - 1]} ${currentPerson.bDay}'
        '${currentPerson.bYear != null ? ', ${currentPerson.bYear}' : ''}';

    final infoRows = <(String, String)>[];
    if (currentPerson.stage == LifeStage.college) {
      if (currentPerson.year.isNotEmpty) {
        infoRows.add(('Year', currentPerson.year));
      }
      if (currentPerson.major.isNotEmpty) {
        infoRows.add(('Major', currentPerson.major));
      }
      if (currentPerson.school.isNotEmpty) {
        infoRows.add(('College', currentPerson.school));
      }
    } else if (currentPerson.stage == LifeStage.teens ||
        currentPerson.stage == LifeStage.kids) {
      if (currentPerson.grade.isNotEmpty) {
        infoRows.add(('Grade', currentPerson.grade));
      }
      if (currentPerson.school.isNotEmpty) {
        infoRows.add(('School', currentPerson.school));
      }
    } else if (currentPerson.occupation.isNotEmpty) {
      infoRows.add(('Occupation', currentPerson.occupation));
    }
    infoRows.add(('Birthday', bdayStr));
    if (currentPerson.location.isNotEmpty) {
      infoRows.add(('Location', currentPerson.location));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, tokens, currentPerson),
              const SizedBox(height: 18),
              _identity(context, tokens, currentPerson, meta, age),
              const SizedBox(height: 24),
              _detailsCard(tokens, infoRows),
              if (currentPerson.interests.isNotEmpty) ...[
                const SizedBox(height: 26),
                _sectionLabel(tokens, 'Interests'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final interest in currentPerson.interests)
                      _pill(
                        key: Key('interest-pill-$interest'),
                        label: interest,
                        bg: tokens.tagWarmBg,
                        textColor: tokens.tagWarmText,
                      ),
                  ],
                ),
              ],
              if (currentPerson.dietary.isNotEmpty) ...[
                const SizedBox(height: 26),
                _sectionLabel(tokens, 'Dietary'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final pref in currentPerson.dietary)
                      _pill(
                        key: Key('dietary-pill-$pref'),
                        label: pref,
                        bg: tokens.tagMintBg,
                        textColor: tokens.tagMintText,
                      ),
                  ],
                ),
              ],
              if (currentPerson.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 26),
                _sectionLabel(tokens, 'Notes & preferences'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tokens.border, width: 1),
                  ),
                  child: Text(
                    currentPerson.notes,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: tokens.text2,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    DesignTokens tokens,
    Person currentPerson,
  ) {
    return Row(
      children: [
        InkWell(
          key: const Key('profile-back'),
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                Text(
                  '‹',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: tokens.muted,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'People',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: tokens.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        const ThemeToggleButton(),
        const SizedBox(width: 10),
        Material(
          color: tokens.accentBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          child: InkWell(
            key: const Key('profile-edit'),
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormScreen(person: currentPerson),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: tokens.accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _identity(
    BuildContext context,
    DesignTokens tokens,
    Person currentPerson,
    LifeStage meta,
    int? age,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: meta.avatarBg,
          child: Text(
            currentPerson.initials,
            style: TextStyle(
              color: meta.avatarColor,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          currentPerson.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.02,
            color: tokens.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: meta.bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: meta.avatarBg,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${meta.label} · ${age != null ? '$age yrs' : '—'}',
                style: TextStyle(
                  color: meta.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (currentPerson.howKnow.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            currentPerson.howKnow,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: tokens.muted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailsCard(DesignTokens tokens, List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Container(height: 1, color: tokens.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Text(
                    rows[i].$1.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08,
                      color: tokens.faint,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tokens.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(DesignTokens tokens, String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.1,
        color: tokens.faint,
      ),
    );
  }

  Widget _pill({
    required Key key,
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
