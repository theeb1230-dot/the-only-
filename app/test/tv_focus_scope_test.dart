import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/a11y/tv_focus_scope.dart';

void main() {
  testWidgets('D-pad arrows move focus deterministically in RTL navigation',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: TvFocusScope(
            child: Row(
              children: const [
                TextButton(onPressed: null, child: Text('disabled')),
                _FocusableButton(key: Key('first'), label: 'first'),
                _FocusableButton(key: Key('second'), label: 'second'),
                _FocusableButton(key: Key('third'), label: 'third'),
              ],
            ),
          ),
        ),
      ),
    );

    final first = tester.widget<_FocusableButton>(find.byKey(const Key('first')));
    first.node.requestFocus();
    await tester.pump();
    expect(first.node.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    final second = tester.widget<_FocusableButton>(find.byKey(const Key('second')));
    expect(second.node.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(first.node.hasFocus, isTrue);
  });
}

class _FocusableButton extends StatelessWidget {
  const _FocusableButton({super.key, required this.label});

  final String label;
  static final Map<String, FocusNode> _nodes = {};
  FocusNode get node => _nodes.putIfAbsent(label, FocusNode.new);

  @override
  Widget build(BuildContext context) => TextButton(
        focusNode: node,
        onPressed: () {},
        child: Text(label),
      );
}
