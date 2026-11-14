




class PlayerAttribute {
  final String code; 
  final String name; 
  final int value;
  final int maxValue;

  const PlayerAttribute({
    required this.code,
    required this.name,
    required this.value,
    this.maxValue = 100,
  });
}

class Player {
  final String name;
  final int level;
  final String rank;
  final int hp;
  final int maxHp;
  final int currentXp;
  final int maxXp;
  final int totalXp;
  final int questsCompleted;
  final int streakDays;
  final List<PlayerAttribute> attributes;

  const Player({
    required this.name,
    required this.level,
    required this.rank,
    this.hp = 100,
    this.maxHp = 100,
    required this.currentXp,
    required this.maxXp,
    required this.totalXp,
    required this.questsCompleted,
    required this.streakDays,
    required this.attributes,
  });

  
  String get formattedLevel => level.toString().padLeft(2, '0');

  
  double get xpProgress =>
      maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0.0;

  
  double get hpProgress => maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;

  
  static const Player demoPlayer = Player(
    name: 'HUNTER',
    level: 7,
    rank: 'E',
    hp: 100,
    maxHp: 100,
    currentXp: 750,
    maxXp: 1000,
    totalXp: 750,
    questsCompleted: 24,
    streakDays: 3,
    attributes: [
      PlayerAttribute(code: 'STR', name: 'STRENGTH', value: 16),
      PlayerAttribute(code: 'INT', name: 'INTELLIGENCE', value: 18),
      PlayerAttribute(code: 'END', name: 'ENDURANCE', value: 14),
      PlayerAttribute(code: 'DIS', name: 'DISCIPLINE', value: 20),
    ],
  );
}


class Quest {
  final String id;
  final String title;
  final String category; 
  final int currentProgress;
  final int targetProgress;
  final String unit;
  final int xpReward;
  final bool isMandatory;
  final bool isCompleted;

  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.currentProgress,
    required this.targetProgress,
    required this.unit,
    required this.xpReward,
    this.isMandatory = true,
    this.isCompleted = false,
  });

  double get progressFraction => targetProgress > 0
      ? (currentProgress / targetProgress).clamp(0.0, 1.0)
      : 0.0;

  
  static const List<Quest> demoSystemQuests = [
    Quest(
      id: 'sq_1',
      title: 'Walk 10,000 Steps',
      category: 'PHYSICAL',
      currentProgress: 6500,
      targetProgress: 10000,
      unit: 'steps',
      xpReward: 100,
      isMandatory: true,
      isCompleted: false,
    ),
    Quest(
      id: 'sq_2',
      title: 'Complete Scheduled Workout',
      category: 'PHYSICAL',
      currentProgress: 1,
      targetProgress: 1,
      unit: 'session',
      xpReward: 150,
      isMandatory: true,
      isCompleted: true,
    ),
    Quest(
      id: 'sq_3',
      title: 'Complete Study Target',
      category: 'INTELLECT',
      currentProgress: 90,
      targetProgress: 120,
      unit: 'minutes',
      xpReward: 120,
      isMandatory: true,
      isCompleted: false,
    ),
    Quest(
      id: 'sq_4',
      title: 'Meet Nutrition Goals',
      category: 'VITALITY',
      currentProgress: 1,
      targetProgress: 1,
      unit: 'goals',
      xpReward: 100,
      isMandatory: true,
      isCompleted: true,
    ),
  ];

  
  static const List<Quest> demoPersonalQuests = [
    Quest(
      id: 'pq_1',
      title: 'Read 20 Pages',
      category: 'MIND',
      currentProgress: 15,
      targetProgress: 20,
      unit: 'pages',
      xpReward: 50,
      isMandatory: false,
      isCompleted: false,
    ),
    Quest(
      id: 'pq_2',
      title: 'Practice Flutter',
      category: 'DISCIPLINE',
      currentProgress: 45,
      targetProgress: 60,
      unit: 'minutes',
      xpReward: 75,
      isMandatory: false,
      isCompleted: false,
    ),
  ];
}
