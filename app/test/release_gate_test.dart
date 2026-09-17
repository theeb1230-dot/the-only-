import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/domain/release_gate.dart';

void main() {
  test('release remains blocked until every gate passes', () {
    expect(const ReleaseGate(testsGreen: true, analysisGreen: true, licensesCleared: false, mobileBuild: true, tvBuild: true).ready, isFalse);
    expect(const ReleaseGate(testsGreen: true, analysisGreen: true, licensesCleared: true, mobileBuild: true, tvBuild: true).ready, isTrue);
  });
}
