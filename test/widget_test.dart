import 'package:flutter_test/flutter_test.dart';
import 'package:go_places/main.dart';
import 'package:go_places/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GoPlacesApp());
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
