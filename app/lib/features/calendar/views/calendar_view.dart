import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CalendarController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SsPage(
      title: l.calendar,
      actions: [
        IconButton(
          tooltip: l.showAllUpcoming,
          onPressed: c.clearSelection,
          icon: Icon(
            Icons.view_list_outlined,
            color: SsLayout.title(scheme),
          ),
        ),
      ],
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: c.error.value);
        }
        final summary = c.data.value?['summary'] as Map? ?? {};
        final filtered = c.filteredOrders;
        final selected = c.selectedDay.value;

        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            padding: SsLayout.pagePaddingBottom(),
            children: [
              Row(
                children: [
                  Expanded(
                    child: SsStatTile(
                      label: l.todayDeliveries,
                      value: '${summary['todayDeliveries'] ?? 0}',
                      icon: Icons.local_shipping_outlined,
                    ),
                  ),
                  const SizedBox(width: SsLayout.tight),
                  Expanded(
                    child: SsStatTile(
                      label: l.overdue,
                      value: '${summary['overdue'] ?? 0}',
                      icon: Icons.warning_amber_outlined,
                      emphasized: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SsLayout.section),
              SsGlassCard(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: c.focusedDay.value,
                      calendarFormat: c.format.value,
                      selectedDayPredicate: (d) =>
                          selected != null && isSameDay(selected, d),
                      onDaySelected: c.onDaySelected,
                      onPageChanged: c.onPageChanged,
                      onFormatChanged: c.onFormatChanged,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.twoWeeks: '2 weeks',
                        CalendarFormat.week: 'Week',
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: true,
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        formatButtonTextStyle: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        titleTextStyle: SsLayout.titleStyle(context),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: SsLayout.title(scheme),
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: SsLayout.title(scheme),
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        weekendTextStyle: TextStyle(
                          color: SsLayout.body(scheme),
                        ),
                        defaultTextStyle: TextStyle(
                          color: SsLayout.title(scheme),
                        ),
                        outsideDaysVisible: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, _) {
                          final trial = c.hasTrial(day);
                          final delivery = c.hasDelivery(day);
                          if (!trial && !delivery) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (trial)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF14B8A6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (delivery)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(
                          color: const Color(0xFF14B8A6),
                          label: l.trialMarker,
                        ),
                        const SizedBox(width: 16),
                        _LegendDot(
                          color: const Color(0xFF3B82F6),
                          label: l.deliveryMarker,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SsSectionTitle(
                selected == null
                    ? l.upcomingDeliveries
                    : '${l.selectedDay} · ${c.iso(selected)}',
              ),
              if (filtered.isEmpty)
                Text(
                  selected == null ? l.empty : l.noEventsOnDay,
                  style: SsLayout.bodyStyle(context),
                )
              else
                ...filtered.map((m) {
                  final cust = m['customer'] as Map? ?? {};
                  return Column(
                    children: [
                      SsListTile(
                        leading: const SsPrimaryIconBox(
                          Icons.event_outlined,
                        ),
                        title: '${m['orderNumber']}',
                        subtitle:
                            '${cust['fullName'] ?? ''} · ${l.orderStatusLabel('${m['status']}')}\n'
                            '${l.trialDate}: ${c.dateOnly(m['trialDate'])} · ${l.deliveryDate}: ${c.dateOnly(m['deliveryDate'])}',
                        onTap: () => Get.toNamed('/orders/${m['id']}'),
                      ),
                      Divider(
                        height: 1,
                        color: scheme.onSurface.withValues(alpha: 0.08),
                      ),
                    ],
                  );
                }),
            ],
          ),
        );
      }),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: SsLayout.captionStyle(context)),
      ],
    );
  }
}
