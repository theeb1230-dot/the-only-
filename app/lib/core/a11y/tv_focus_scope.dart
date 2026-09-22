import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps TV remote directional/select keys onto Flutter's focus/action system.
///
/// This stays platform-agnostic so the same shell works with Android TV
/// remotes, keyboards used for TV testing, and accessibility switch devices.
class TvFocusScope extends StatelessWidget {
  const TvFocusScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            isRtl ? const PreviousFocusIntent() : const NextFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            isRtl ? const NextFocusIntent() : const PreviousFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
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
