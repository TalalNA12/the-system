import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_system/main.dart';

void main() {
  testWidgets(
    'THE SYSTEM smoke test and Solo Leveling UI verification (390x844)',
    (WidgetTester tester) async {
      
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      
      await tester.pumpWidget(const TheSystemApp());
      await tester.pump(const Duration(milliseconds: 200));

      
      expect(find.text('THE SYSTEM'), findsWidgets);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.textContaining('HUNTER'), findsWidgets);
      expect(find.textContaining('07'), findsWidgets);
      expect(find.textContaining('E'), findsWidgets);
      expect(find.text('HP'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);

      
      expect(find.text('QUEST INFO'), findsOneWidget);
      expect(
        find.text('[Daily Quest: Strength Training has arrived.]'),
        findsOneWidget,
      );
      expect(find.text('GOAL'), findsOneWidget);
      expect(find.textContaining('WARNING:'), findsOneWidget);

      
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('QUESTS'), findsOneWidget);
      expect(find.text('FITNESS'), findsOneWidget);
      expect(find.text('CALENDAR'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);

      
      await tester.tap(find.text('QUESTS'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('MANDATORY GOALS'), findsOneWidget);
      expect(find.text('PERSONAL GOALS'), findsOneWidget);
      expect(find.text('QUEST REWARDS'), findsOneWidget);
      expect(find.text('+ INITIALIZE PERSONAL QUEST'), findsOneWidget);

      
      await tester.tap(find.text('FITNESS'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('PHYSICAL STATUS'), findsOneWidget);
      expect(find.text('TRAINING RECORD'), findsOneWidget);
      expect(find.text('NUTRITION STATUS'), findsOneWidget);

      
      await tester.tap(find.text('CALENDAR'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('TIMELINE'), findsOneWidget);
      expect(find.text('RECORD LOG'), findsOneWidget);

      
      await tester.tap(find.text('PROFILE'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('ATTRIBUTES'), findsOneWidget);
      expect(find.text('LOCKED TITLES'), findsOneWidget);
    },
  );

  testWidgets('THE SYSTEM responsive test on compact mobile (375x812)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TheSystemApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('THE SYSTEM'), findsWidgets);
    expect(find.textContaining('HUNTER'), findsWidgets);
  });

  testWidgets(
    'THE SYSTEM desktop viewport max-width constrain test (1024x768)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const TheSystemApp());
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('THE SYSTEM'), findsWidgets);
      expect(find.textContaining('HUNTER'), findsWidgets);
    },
  );
}
