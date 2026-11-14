import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/system_header.dart';
import '../widgets/system_window.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, now.day);
    _selectedDate = _currentDate;
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  String _getMonthName(int month) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[month - 1];
  }

  String _formatDateString(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SystemHeader(title: 'THE SYSTEM', subtitle: 'CHRONO ARCHIVE'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 2.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    _buildTimelineWindow(),

                    const SizedBox(height: 10),

                    
                    _buildRecordLogWindow(),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineWindow() {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final totalDaysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; 
    final leadingEmptyDays = firstWeekday - 1;

    return SystemWindow(
      title: 'TIMELINE',
      subtitle: '[${_getMonthName(month)} $year]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppTheme.electricCyan,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _previousMonth,
              ),
              Text(
                '${_getMonthName(month)} $year',
                style: AppTheme.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.textWhite,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.electricCyan,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),

          
          Row(
            children: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTheme.sans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),

          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmptyDays + totalDaysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyDays) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - leadingEmptyDays + 1;
              final cellDate = DateTime(year, month, dayNumber);
              final isToday =
                  cellDate.year == _currentDate.year &&
                  cellDate.month == _currentDate.month &&
                  cellDate.day == _currentDate.day;
              final isSelected =
                  cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              final bool isPastCompleted =
                  cellDate.isBefore(_currentDate) && dayNumber % 2 == 0;

              Color bg = const Color(0x22040E20);
              Color border = AppTheme.electricCyan.withValues(alpha: 0.12);
              Color text = AppTheme.textWhite;

              if (isSelected) {
                bg = AppTheme.electricCyan.withValues(alpha: 0.25);
                border = AppTheme.electricCyan;
                text = AppTheme.textWhite;
              } else if (isToday) {
                bg = const Color(0x44081E3C);
                border = AppTheme.electricCyan;
                text = AppTheme.electricCyan;
              }

              return InkWell(
                onTap: () => _selectDate(cellDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(
                      color: border,
                      width: isSelected || isToday ? 1.0 : 0.6,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$dayNumber',
                          style: AppTheme.sans(
                            fontSize: 11,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: text,
                          ),
                        ),
                      ),
                      if (isPastCompleted)
                        Positioned(
                          bottom: 2,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppTheme.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordLogWindow() {
    final isToday =
        _selectedDate.year == _currentDate.year &&
        _selectedDate.month == _currentDate.month &&
        _selectedDate.day == _currentDate.day;

    return SystemWindow(
      title: 'RECORD LOG',
      subtitle: '[${_formatDateString(_selectedDate)} Summary]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow(
            'Quests Completed',
            isToday ? '[2 / 4 Completed] (50%)' : '[4 / 4 Completed] (100%)',
            AppTheme.textWhite,
          ),
          const SizedBox(height: 6),
          _buildSummaryRow(
            'Experience Gained',
            isToday ? '[+250 XP]' : '[+470 XP]',
            AppTheme.softBlue,
          ),
          const SizedBox(height: 6),
          _buildSummaryRow(
            'Penalty Status',
            '[None Recorded]',
            AppTheme.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
