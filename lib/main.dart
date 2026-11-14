import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'widgets/system_window.dart';
import 'services/system_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TheSystemApp());
}

class TheSystemApp extends StatelessWidget {
  const TheSystemApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'THE SYSTEM',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: const SystemMvp(),
  );
}

class SystemMvp extends StatefulWidget {
  const SystemMvp({super.key});
  @override
  State<SystemMvp> createState() => _SystemMvpState();
}

class _SystemMvpState extends State<SystemMvp> with WidgetsBindingObserver {
  final _storageKey = 'the_system_mvp_v1';
  bool loading = true;
  int tab = 0;
  String name = '';
  int totalXp = 0;
  int completedCount = 0;
  String lastDate = '';
  bool penalty = false;
  bool demoPenalty = false;
  String split = 'full3';
  List<int> customDays = [1, 3, 5];
  bool splitConfigured = false;
  int pageRevision = 0;

  List<int> get trainingDays {
    if (split == 'five') return [1, 2, 3, 4, 5];
    if (split == 'custom') return customDays;
    return [1, 3, 5];
  }

  String get splitName {
    if (split == 'five') return 'FIVE-DAY SPLIT';
    if (split == 'custom') return 'CUSTOM SPLIT';
    return 'FULL BODY - 3 DAYS';
  }

  String get trainingDayNames {
    const names = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return trainingDays.map((day) => names[day - 1]).join(' / ');
  }

  Map<String, dynamic> logs = {};
  DateTime selectedDate = DateTime.now();

  String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String get today => dateKey(DateTime.now());
  Map<String, dynamic> get day => Map<String, dynamic>.from(logs[today] ?? {});
  int number(Map<String, dynamic> x, String field) =>
      (x[field] as num?)?.toInt() ?? 0;
  List<String> claimed(Map<String, dynamic> d) =>
      List<String>.from(d['claimed'] ?? []);
  bool get workoutDay => trainingDays.contains(DateTime.now().weekday);

  bool scheduledFor(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return false;
    final record = Map<String, dynamic>.from(logs[date] ?? {});
    final storedDays = record['scheduledDays'];
    if (storedDays is List) {
      return storedDays
          .whereType<num>()
          .map((n) => n.toInt())
          .contains(parsed.weekday);
    }
    return trainingDays.contains(parsed.weekday);
  }

  int get level {
    var lvl = 1;
    var rest = totalXp;
    while (rest >= lvl * 200) {
      rest -= lvl * 200;
      lvl++;
    }
    return lvl;
  }

  int get levelXp {
    var rest = totalXp;
    for (var i = 1; i < level; i++) {
      rest -= i * 200;
    }
    return rest;
  }

  String get rank => level >= 51
      ? 'S'
      : level >= 41
      ? 'A'
      : level >= 31
      ? 'B'
      : level >= 21
      ? 'C'
      : level >= 11
      ? 'D'
      : 'E';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_advanceDay());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = Map<String, dynamic>.from(jsonDecode(raw));
        name = data['name'] as String? ?? '';
        totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
        completedCount = (data['completedCount'] as num?)?.toInt() ?? 0;
        lastDate = data['lastDate'] as String? ?? '';
        penalty = data['penalty'] == true;
        demoPenalty = data['demoPenalty'] == true;
        split = data['split'] as String? ?? 'full3';
        splitConfigured = data['splitConfigured'] == true;
        final storedDays = data['customDays'];
        if (storedDays is List) {
          customDays =
              storedDays
                  .whereType<num>()
                  .map((n) => n.toInt())
                  .where((d) => d >= 1 && d <= 7)
                  .toSet()
                  .toList()
                ..sort();
          if (customDays.isEmpty) customDays = [1, 3, 5];
        }

        logs = Map<String, dynamic>.from(data['logs'] ?? {});
      }
    } catch (e) {
      debugPrint('Saved data could not be loaded: $e');
    }
    if (lastDate.isEmpty) lastDate = today;
    await _processDayChange();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'name': name,
        'totalXp': totalXp,
        'completedCount': completedCount,
        'lastDate': lastDate,
        'penalty': penalty,
        'demoPenalty': demoPenalty,
        'split': split,
        'customDays': customDays,
        'splitConfigured': splitConfigured,
        'logs': logs,
      }),
    );
  }

  Future<void> _advanceDay() async {
    if (lastDate != today) {
      await _processDayChange();
      if (mounted) setState(() {});
    }
  }

  Future<void> _processDayChange() async {
    if (lastDate == today) return;
    final previous = Map<String, dynamic>.from(logs[lastDate] ?? {});

    final scheduled = scheduledFor(lastDate);
    final earned = claimed(previous);
    final needed = ['steps', 'study', 'nutrition', if (scheduled) 'workout'];
    final missed = needed.any((q) => !earned.contains(q));
    if (penalty && !demoPenalty) {
      totalXp = (totalXp - 50).clamp(0, 999999999).toInt();
    }
    penalty = missed;
    demoPenalty = false;
    lastDate = today;
    await _save();
  }

  void _persist() {
    unawaited(_save());
    setState(() {});
  }

  Future<void> _notice(
    String heading,
    String detail, {
    SystemEffect? sound,
  }) async {
    if (sound != null) unawaited(SystemAudio.instance.play(sound));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.84),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SystemWindow(
            title: heading,
            isWarning: sound == SystemEffect.penalty,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: AppTheme.sans(fontSize: 14),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ACCEPT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _claim(String id, int reward) {
    final d = day;
    final earned = claimed(d);
    if (earned.contains(id)) return;
    earned.add(id);
    d['claimed'] = earned;
    logs[today] = d;
    final oldLevel = level;
    totalXp += reward;
    completedCount++;
    _persist();
    if (level > oldLevel) {
      _notice(
        'LEVEL UP',
        'LEVEL $oldLevel  →  $level\nRANK $rank',
        sound: SystemEffect.levelUp,
      );
    } else {
      _notice(
        'QUEST COMPLETE',
        '+$reward XP',
        sound: SystemEffect.questComplete,
      );
    }
  }

  void _update(String field, int value) {
    final d = day;
    d['scheduledDays'] ??= List<int>.from(trainingDays);
    d[field] = value;
    logs[today] = d;
    _persist();
    if (field == 'steps' && value >= 10000) _claim('steps', 100);
    if (field == 'study' && value >= 120) _claim('study', 120);
    if (field == 'workout' && value >= 1 && workoutDay) _claim('workout', 150);
    if (field == 'penaltyMinutes' && value >= 15 && penalty) {
      penalty = false;
      demoPenalty = false;
      _persist();
      _notice(
        'PENALTY CLEARED',
        'Your standing has been restored.',
        sound: SystemEffect.questComplete,
      );
    }
    if ((field == 'calories' || field == 'protein') &&
        number(d, 'calories') >= 1600 &&
        number(d, 'calories') <= 2600 &&
        number(d, 'protein') >= 120) {
      _claim('nutrition', 100);
    }
  }

  Future<void> _askNumber(
    String title,
    String field, {
    String? description,
  }) async {
    final controller = TextEditingController(text: '${number(day, field)}');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.windowGlass,
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (description != null) Text(description),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total for today'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result >= 0) _update(field, result);
  }

  Future<void> _addWorkout() async {
    final exercise = TextEditingController();
    final sets = TextEditingController(text: '3');
    final reps = TextEditingController(text: '8');
    final weight = TextEditingController(text: '0');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.windowGlass,
        title: const Text('LOG EXERCISE'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exercise,
                decoration: const InputDecoration(labelText: 'Exercise'),
              ),
              TextField(
                controller: sets,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
              TextField(
                controller: reps,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
              TextField(
                controller: weight,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (exercise.text.trim().isEmpty) return;
              Navigator.pop(ctx, {
                'name': exercise.text.trim(),
                'sets': int.tryParse(sets.text) ?? 0,
                'reps': int.tryParse(reps.text) ?? 0,
                'kg': double.tryParse(weight.text) ?? 0.0,
              });
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
    exercise.dispose();
    sets.dispose();
    reps.dispose();
    weight.dispose();
    if (result == null) return;
    final d = day;
    final entries = List<dynamic>.from(d['exercises'] ?? []);
    entries.add(result);
    d['scheduledDays'] ??= List<int>.from(trainingDays);
    d['exercises'] = entries;
    logs[today] = d;
    _persist();
  }

  Future<void> _newPersonalQuest() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.windowGlass,
        title: const Text('NEW PERSONAL QUEST'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Quest name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('ADD'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    final d = day;
    final personal = List<dynamic>.from(d['personal'] ?? []);
    personal.add({
      'id': 'personal_${DateTime.now().microsecondsSinceEpoch}',
      'title': title,
    });
    d['scheduledDays'] ??= List<int>.from(trainingDays);
    d['personal'] = personal;
    logs[today] = d;
    _persist();
  }

  Widget _line(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: AppTheme.sans(color: AppTheme.textMuted)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.sans(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  Widget _button(String text, VoidCallback tap) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: OutlinedButton(
      onPressed: tap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.softBlue,
        side: const BorderSide(color: AppTheme.iceBlue),
      ),
      child: Text(text),
    ),
  );
  int _windowOrder = 0;

  Widget _window(String title, List<Widget> children, {bool warning = false}) {
    final order = _windowOrder++;
    return SystemReveal(
      key: ValueKey('screen-$tab-$pageRevision-$order'),
      delay: Duration(milliseconds: (order * 150).clamp(0, 600).toInt()),
      child: SystemWindow(
        title: title,
        isWarning: warning,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  void _switchTab(int next) {
    if (tab == next) return;
    unawaited(SystemAudio.instance.play(SystemEffect.open));
    setState(() {
      tab = next;
      pageRevision++;
    });
  }

  Widget _quest(
    String id,
    String title,
    int current,
    int target,
    int reward, {
    VoidCallback? tap,
  }) {
    final done = claimed(day).contains(id);
    return InkWell(
      onTap: tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: done ? const Color(0xFFEAF8FF) : Colors.transparent,
                border: Border.all(color: const Color(0xFFEAF8FF), width: 1.1),
                boxShadow: done
                    ? [
                        const BoxShadow(
                          color: Color(0x9974CFFF),
                          blurRadius: 10,
                        ),
                      ]
                    : const [],
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Color(0xFF061426))
                  : null,
            ),
            const SizedBox(width: 9),
            Expanded(child: Text(title, style: AppTheme.sans(fontSize: 12))),
            Text(
              '$current/$target  +$reward XP',
              style: AppTheme.sans(fontSize: 10, color: AppTheme.softBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _home() {
    final d = day;
    final done = claimed(d);
    final required = ['steps', 'study', 'nutrition', if (workoutDay) 'workout'];
    final count = required.where(done.contains).length;
    return Column(
      children: [
        _window('PLAYER STATUS', [
          _line('NAME', name.toUpperCase()),
          _line('LEVEL', '$level'),
          _line('RANK', rank),
          _line('TOTAL XP', '$totalXp'),
          LinearProgressIndicator(
            value: levelXp / (level * 200),
            color: AppTheme.electricCyan,
            backgroundColor: AppTheme.windowGlassDeep,
          ),
          _line('NEXT LEVEL', '$levelXp / ${level * 200} XP'),
        ]),
        _window('DAILY QUESTS', [
          _line('COMPLETION', '$count / ${required.length}'),
          _quest(
            'steps',
            'Walk 10,000 Steps',
            number(d, 'steps'),
            10000,
            100,
            tap: () => _askNumber('STEPS', 'steps'),
          ),
          if (workoutDay)
            _quest(
              'workout',
              'Complete Workout',
              number(d, 'workout'),
              1,
              150,
              tap: () => _switchTab(2),
            ),
          _quest(
            'study',
            'Study for 120 Minutes',
            number(d, 'study'),
            120,
            120,
            tap: () => _askNumber('STUDY MINUTES', 'study'),
          ),
          _quest(
            'nutrition',
            'Nutrition Goal',
            done.contains('nutrition') ? 1 : 0,
            1,
            100,
            tap: () => _switchTab(2),
          ),
        ]),
        if (penalty) _penaltyWidget(),
      ],
    );
  }

  Widget _penaltyWidget() => _window('PENALTY QUEST', [
    Text(
      demoPenalty
          ? 'DEMO PENALTY — NOT A REAL MISSED DAY'
          : 'An earlier daily quest was missed.',
      style: AppTheme.sans(fontSize: 12),
    ),
    const SizedBox(height: 10),
    const Text('Complete a 15-minute recovery study session.'),
    _line('RECOVERY STUDY', '${number(day, 'penaltyMinutes')} / 15 min'),
    _button(
      'LOG RECOVERY MINUTES',
      () => _askNumber('PENALTY STUDY', 'penaltyMinutes'),
    ),
  ], warning: true);

  Widget _quests() {
    final d = day;
    final personal = List<dynamic>.from(d['personal'] ?? []);
    return Column(
      children: [
        _window('SYSTEM QUESTS', [
          _quest(
            'steps',
            'Walk 10,000 Steps',
            number(d, 'steps'),
            10000,
            100,
            tap: () => _askNumber('STEPS', 'steps'),
          ),
          if (workoutDay)
            _quest(
              'workout',
              'Scheduled Workout',
              number(d, 'workout'),
              1,
              150,
              tap: () => _switchTab(2),
            ),
          _quest(
            'study',
            'Study 120 Minutes',
            number(d, 'study'),
            120,
            120,
            tap: () => _askNumber('STUDY MINUTES', 'study'),
          ),
          _quest(
            'nutrition',
            'Nutrition Target',
            claimed(d).contains('nutrition') ? 1 : 0,
            1,
            100,
            tap: () => _switchTab(2),
          ),
        ]),
        _window('PERSONAL QUESTS', [
          for (final item in personal)
            _quest(
              item['id'] as String,
              item['title'] as String,
              claimed(d).contains(item['id']) ? 1 : 0,
              1,
              50,
              tap: () => _claim(item['id'] as String, 50),
            ),
          _button('+ ADD PERSONAL QUEST', _newPersonalQuest),
        ]),
        if (penalty) _penaltyWidget(),
        _button('DEMO: TRIGGER PENALTY', () {
          if (penalty) return;
          setState(() {
            penalty = true;
            demoPenalty = true;
          });
          _persist();
          _notice(
            'PENALTY QUEST',
            'An additional challenge has appeared.',
            sound: SystemEffect.penalty,
          );
        }),
      ],
    );
  }

  Widget _fitness() {
    final d = day;
    final exercises = List<dynamic>.from(d['exercises'] ?? []);
    return Column(
      children: [
        _window('STEP TRACKER', [
          _line('DAILY STEPS', '${number(d, 'steps')} / 10000'),
          _button('LOG STEPS', () => _askNumber('TOTAL STEPS', 'steps')),
        ]),
        _window('TRAINING RECORD', [
          _line('SPLIT', splitName),
          _line('TRAINING DAYS', trainingDayNames),
          _line('TODAY', workoutDay ? 'TRAINING DAY' : 'REST DAY'),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No exercises logged today.',
                style: AppTheme.sans(color: AppTheme.textMuted),
              ),
            ),
          for (final e in exercises)
            _line(
              '${e['name']}',
              '${e['sets']} × ${e['reps']} · ${e['kg']} kg',
            ),
          _button('ADD EXERCISE', _addWorkout),
          _button(
            claimed(d).contains('workout')
                ? 'WORKOUT COMPLETED'
                : 'FINISH WORKOUT',
            () {
              if (claimed(day).contains('workout') ||
                  number(day, 'workout') == 1) {
                return;
              }
              if (exercises.isEmpty) {
                unawaited(
                  _notice(
                    'WORKOUT REQUIRED',
                    'Record at least one exercise before finishing.',
                    sound: SystemEffect.penalty,
                  ),
                );
                return;
              }
              _update('workout', 1);
              if (!workoutDay) {
                unawaited(
                  _notice(
                    'TRAINING RECORDED',
                    'Rest-day workout saved. No mandatory quest today.',
                    sound: SystemEffect.open,
                  ),
                );
              }
            },
          ),
        ]),
        _window('STUDY LOG', [
          _line('MINUTES', '${number(d, 'study')} / 120'),
          _button(
            'LOG STUDY MINUTES',
            () => _askNumber('STUDY MINUTES', 'study'),
          ),
        ]),
        _window('NUTRITION STATUS', [
          _line('CALORIES', '${number(d, 'calories')} kcal (target 1600–2600)'),
          _line('PROTEIN', '${number(d, 'protein')} g (minimum 120)'),
          _line('CARBS', '${number(d, 'carbs')} g'),
          _line('FATS', '${number(d, 'fats')} g'),
          _button('LOG CALORIES', () => _askNumber('CALORIES', 'calories')),
          _button('LOG PROTEIN', () => _askNumber('PROTEIN (g)', 'protein')),
          _button('LOG CARBS', () => _askNumber('CARBS (g)', 'carbs')),
          _button('LOG FATS', () => _askNumber('FATS (g)', 'fats')),
        ]),
      ],
    );
  }

  Widget _calendar() {
    final key = dateKey(selectedDate);
    final record = Map<String, dynamic>.from(logs[key] ?? {});
    final completed = claimed(record);
    return Column(
      children: [
        _window('SYSTEM CALENDAR', [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2035),
            onDateChanged: (date) => setState(() => selectedDate = date),
          ),
        ]),
        _window('DAILY RECORD — $key', [
          _line('QUESTS COMPLETED', '${completed.length}'),
          _line('STEPS', '${number(record, 'steps')}'),
          _line('STUDY MINUTES', '${number(record, 'study')}'),
          _line('CALORIES', '${number(record, 'calories')}'),
          _line(
            'EXERCISES',
            '${List<dynamic>.from(record['exercises'] ?? []).length}',
          ),
          if (record.isEmpty) const Text('No activity recorded for this date.'),
        ]),
      ],
    );
  }

  Widget _profile() => Column(
    children: [
      _window('PLAYER STATUS', [
        _line('NAME', name.toUpperCase()),
        _line('LEVEL', '$level'),
        _line('RANK', rank),
        _line('TOTAL XP', '$totalXp'),
        _line('QUESTS COMPLETED', '$completedCount'),
      ]),
      _window('TRAINING REGIMEN', [
        _line('SPLIT', splitName),
        _line('DAYS', trainingDayNames),
        _button('CHANGE WORKOUT SPLIT', () => unawaited(_changeSplit())),
      ]),
      _window('MYTHOLOGICAL TITLES', [
        const Text(
          'LOCKED — Future updates will introduce the Trials of Heracles, Athena, and Tartarus.',
        ),
      ]),
      _button(SystemAudio.instance.enabled ? 'MUTE AUDIO' : 'ENABLE AUDIO', () {
        setState(
          () => SystemAudio.instance.setMuted(SystemAudio.instance.enabled),
        );
      }),
    ],
  );

  Future<void> _changeSplit({bool requiredSelection = false}) async {
    String choice = split;
    final selectedDays = customDays.toSet();
    final result = await showDialog<(String, List<int>)>(
      context: context,
      barrierDismissible: !requiredSelection,
      builder: (dialogContext) => PopScope(
        canPop: !requiredSelection,
        child: StatefulBuilder(
          builder: (context, updateDialog) {
            Widget option(String value, String heading, String sub) {
              final selected = choice == value;
              return InkWell(
                onTap: () => updateDialog(() => choice = value),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.iceBlue.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppTheme.softBlue : AppTheme.textMuted,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected ? Colors.white : AppTheme.softBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              heading,
                              style: AppTheme.sans(
                                fontWeight: FontWeight.bold,
                                glow: selected,
                              ),
                            ),
                            Text(
                              sub,
                              style: AppTheme.sans(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  child: SystemWindow(
                    title: 'TRAINING PROTOCOL',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SystemGoalHeader(title: 'SELECT REGIMEN'),
                        const SizedBox(height: 14),
                        option(
                          'full3',
                          'FULL BODY - 3 DAYS',
                          'Monday / Wednesday / Friday',
                        ),
                        option('five', '5-DAY SPLIT', 'Monday through Friday'),
                        option(
                          'custom',
                          'CUSTOM SPLIT',
                          'Choose your own training days',
                        ),
                        if (choice == 'custom') ...[
                          const SizedBox(height: 12),
                          Text(
                            'TRAINING DAYS',
                            style: AppTheme.sans(glow: true),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (var weekday = 1; weekday <= 7; weekday++)
                                FilterChip(
                                  label: Text(
                                    const [
                                      'MO',
                                      'TU',
                                      'WE',
                                      'TH',
                                      'FR',
                                      'SA',
                                      'SU',
                                    ][weekday - 1],
                                  ),
                                  selected: selectedDays.contains(weekday),
                                  onSelected: (selected) => updateDialog(() {
                                    if (selected) {
                                      selectedDays.add(weekday);
                                    } else {
                                      selectedDays.remove(weekday);
                                    }
                                  }),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: choice == 'custom' && selectedDays.isEmpty
                              ? null
                              : () {
                                  final days = selectedDays.toList()..sort();
                                  Navigator.pop(dialogContext, (choice, days));
                                },
                          child: const Text('CONFIRM REGIMEN'),
                        ),
                        if (!requiredSelection)
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('CANCEL'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      split = result.$1;
      customDays = result.$2;
      splitConfigured = true;
      final d = day;

      d['scheduledDays'] ??= List<int>.from(trainingDays);
      logs[today] = d;
    });
    _persist();
  }

  Future<void> _createPlayer() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppTheme.windowGlass,
          title: const Text('SYSTEM AWAKENING'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Enter player name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final entered = controller.text.trim();
                if (entered.isNotEmpty) Navigator.pop(dialogContext, entered);
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || result == null || result.isEmpty) return;
    setState(() {
      name = result;
      lastDate = today;
    });
    _persist();
    await _changeSplit(requiredSelection: true);
    if (!mounted) return;
    unawaited(
      _notice(
        'PLAYER AWAKENED',
        'Welcome, $name.\nLEVEL 1 - RANK E\n$splitName',
        sound: SystemEffect.open,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (name.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SystemWindow(
              title: 'AWAKENING',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('A new player has been detected.'),
                  const SizedBox(height: 18),
                  _button('BEGIN AWAKENING', _createPlayer),
                ],
              ),
            ),
          ),
        ),
      );
    }
    _windowOrder = 0;
    final page = switch (tab) {
      0 => _home(),
      1 => _quests(),
      2 => _fitness(),
      3 => _calendar(),
      _ => _profile(),
    };
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'THE SYSTEM',
                    style: AppTheme.titleStyle(fontSize: 17),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: KeyedSubtree(
                      key: ValueKey('page-$tab-$pageRevision'),
                      child: page,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.windowGlass,
        selectedItemColor: AppTheme.softBlue,
        unselectedItemColor: AppTheme.textMuted,
        currentIndex: tab,
        onTap: _switchTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'QUESTS'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'ACTIVITY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'CALENDAR',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}

class SystemReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const SystemReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<SystemReveal> createState() => _SystemRevealState();
}

class _SystemRevealState extends State<SystemReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: (progress * 1.7).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - progress)),
            child: Transform.scale(
              alignment: Alignment.center,
              scaleX: 0.94 + progress * 0.06,
              scaleY: 0.20 + progress * 0.80,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
