import 'package:flutter/material.dart';

import '../../app/theme.dart';

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.glow = EcoGuardianTheme.neon,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: padding,
      decoration: BoxDecoration(
        color: EcoGuardianTheme.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glow.withOpacity(.22)),
        boxShadow: [
          BoxShadow(color: glow.withOpacity(.14), blurRadius: 28, spreadRadius: -10),
        ],
      ),
      child: child,
    );
  }
}
