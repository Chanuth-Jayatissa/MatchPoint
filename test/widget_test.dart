import 'package:flutter_test/flutter_test.dart';
import 'package:match_point/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MatchPointApp());
    expect(find.text('Find Players Nearby'), findsOneWidget);
  });
}
