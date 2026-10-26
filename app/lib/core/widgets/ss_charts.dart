import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/ss_layout.dart';
import 'ss_widgets.dart';

Color ssStatusColor(String? status, ColorScheme scheme) => switch (status) {
      'NEW' => const Color(0xFF3B82F6),
      'CUTTING' => const Color(0xFFF59E0B),
      'STITCHING' => const Color(0xFF8B5CF6),
      'TRIAL' => const Color(0xFF14B8A6),
      'READY' => const Color(0xFF22C55E),
      'DELIVERED' => scheme.onSurface.withValues(alpha: 0.45),
      'CANCELLED' => const Color(0xFFEF4444),
      _ => scheme.primary,
    };

class SsStatusPieChart extends StatelessWidget {
  const SsStatusPieChart({
    super.key,
    required this.slices,
    required this.emptyLabel,
  });

  final List<({String status, String label, int count})> slices;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = slices.fold<int>(0, (s, e) => s + e.count);
    if (total <= 0) {
      return SsGlassCard(
        padding: const EdgeInsets.all(SsLayout.section),
        child: SizedBox(
          height: 160,
          child: Center(
            child: Text(emptyLabel, style: SsLayout.bodyStyle(context)),
          ),
        ),
      );
    }

    return SsGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: [
                  for (final s in slices)
                    if (s.count > 0)
                      PieChartSectionData(
                        value: s.count.toDouble(),
                        color: ssStatusColor(s.status, scheme),
                        radius: 48,
                        title: '${s.count}',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final s in slices)
                if (s.count > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ssStatusColor(s.status, scheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${s.label} (${s.count})',
                        style: SsLayout.captionStyle(context),
                      ),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class SsMoneyBarChart extends StatelessWidget {
  const SsMoneyBarChart({
    super.key,
    required this.orderValue,
    required this.collections,
    required this.outstanding,
    required this.orderValueLabel,
    required this.collectionsLabel,
    required this.outstandingLabel,
  });

  final double orderValue;
  final double collections;
  final double outstanding;
  final String orderValueLabel;
  final String collectionsLabel;
  final String outstandingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final values = [orderValue, collections, outstanding];
    final maxY = values.fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.2;
    final labels = [orderValueLabel, collectionsLabel, outstandingLabel];
    final colors = [
      scheme.primary,
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
    ];

    return SsGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.onSurface.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (v, _) => Text(
                        _shortMoney(v),
                        style: SsLayout.captionStyle(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SsLayout.captionStyle(context).copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < values.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          color: colors[i],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortMoney(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toInt().toString();
  }
}
