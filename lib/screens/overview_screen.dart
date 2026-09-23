import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PeopleProvider>(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final ov = provider.overviewData;

    final total = ov['total'] as int;
    final bdaysThisMonth = ov['bdaysThisMonth'] as int;
    final stageBars = ov['stageBars'] as List<dynamic>;
    final locations = ov['locations'] as List<dynamic>;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: theme.textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(
                'Insights & stats across your circle',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              // Stat Cards Row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL PEOPLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: tokens.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$total',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 32,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THIS MONTH BDAYS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: tokens.muted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$bdaysThisMonth',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 32,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Life Stage Breakdown
              Text('Life Stage Breakdown', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: stageBars.map((bar) {
                      final label = bar['label'] as String;
                      final count = bar['count'] as int;
                      final color = bar['color'] as Color;
                      final pct = bar['pct'] as String;
                      final pctVal = total > 0 ? count / total : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                Text(
                                  '$count ($pct)',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pctVal,
                                minHeight: 10,
                                backgroundColor: tokens.track,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Top Locations
              Text('Top Locations', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: locations.map((loc) {
                      final name = loc['name'] as String;
                      final count = loc['count'] as int;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tokens.divider,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count ${count == 1 ? 'person' : 'people'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
