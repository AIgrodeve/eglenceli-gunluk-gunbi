import 'package:eglenceli_gunluk_gunbi/core/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows Gunbi onboarding welcome', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FunJournalApp());
    await tester.pumpAndSettle();

    expect(find.text('Merhaba! Ben Günbi!'), findsOneWidget);
    expect(find.text('Başlayalım!'), findsOneWidget);
  });
}
