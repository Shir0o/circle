import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/overview_stats.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final tokens = context.tokens;
    final stats = provider.overviewStats;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(tokens),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _statTile(
                      key: const Key('overview-total-tile'),
                      valueKey: const Key('overview-total'),
                      value: '${stats.total}',
                      valueColor: tokens.text,
                      label: 'people total',
                      labelColor: tokens.muted,
                      bg: tokens.surface,
                      border: tokens.border,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statTile(
                      key: const Key('overview-birthday-tile'),
                      valueKey: const Key('overview-birthdays'),
                      value: '${stats.birthdaysThisMonth}',
                      valueColor: tokens.accent,
                      label: 'birthdays this month',
                      labelColor: tokens.accentDeep,
                      bg: tokens.accentBg,
                      border: tokens.accentBorder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _lifeStageCard(tokens, stats.stageStats),
              const SizedBox(height: 18),
              _topLocationsCard(tokens, stats.topLocations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(DesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your circle',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.02,
            color: tokens.text,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A quick look at everyone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: tokens.muted,
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required Key key,
    required Key valueKey,
    required String value,
    required Color valueColor,
    required String label,
    required Color labelColor,
    required Color bg,
    required Color border,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            key: valueKey,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lifeStageCard(DesignTokens tokens, List<StageStat> stageStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _microLabel(tokens, 'By life stage'),
          const SizedBox(height: 14),
          for (final stat in stageStats)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _stageRow(tokens, stat),
            ),
        ],
      ),
    );
  }

  Widget _stageRow(DesignTokens tokens, StageStat stat) {
    final stage = stat.stage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: stage.avatarBg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              stage.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: tokens.text,
              ),
            ),
            const Spacer(),
            Text(
              '${stat.count}',
              key: Key('overview-stage-count-${stage.serialized}'),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: tokens.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 9,
            color: tokens.track,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              key: Key('overview-stage-bar-${stage.serialized}'),
              widthFactor: stat.fraction,
              child: Container(color: stage.avatarBg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topLocationsCard(DesignTokens tokens, List<LocationStat> locations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _microLabel(tokens, 'Top locations'),
          if (locations.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final loc in locations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: tokens.text,
                        ),
                      ),
                    ),
                    Text(
                      '${loc.count}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: tokens.muted,
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

  Widget _microLabel(DesignTokens tokens, String label) {
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
}
