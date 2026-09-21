import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps TV remote directional keys onto Flutter's focus traversal system.
///
/// This stays platform-agnostic so the same shell works with Android TV
/// remotes, keyboards used for TV testing, and accessibility switch devices.
class TvFocusScope extends StatelessWidget {
  const TvFocusScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NextFocusIntent: CallbackAction<NextFocusIntent>(
            onInvoke: (_) {
              FocusManager.instance.primaryFocus?.nextFocus();
              return null;
            },
          ),
          PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
            onInvoke: (_) {
              FocusManager.instance.primaryFocus?.previousFocus();
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: child,
        ),
      ),
    );
  }
}
