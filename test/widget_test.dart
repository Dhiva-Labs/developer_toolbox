import 'package:developer_toolbox/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Future<void> main() async {
  setUpAll(() async {
    Hive.init('.dart_tool/test_hive');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('home screen shows tools and search filters them',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeveloperToolboxApp()));
    await tester.pumpAndSettle();

    expect(find.text('Developer Toolbox'), findsOneWidget);
    expect(find.text('Case Converter'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'jwt');
    await tester.pumpAndSettle();

    expect(find.text('JWT Decoder'), findsOneWidget);
    expect(find.text('Case Converter'), findsNothing);
  });
}
