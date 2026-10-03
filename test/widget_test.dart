import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echo_music_flutter/core/database/local_storage.dart';
import 'package:echo_music_flutter/app/app.dart';

void main() {
  testWidgets('Echo Music smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    await tester.pumpWidget(EchoMusicApp(storage: storage));
    expect(find.text('Echo Music'), findsWidgets);
  });
}
