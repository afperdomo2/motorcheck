import 'package:flutter/material.dart';

/// Fila con una barra lateral de color según la severidad. Se usa en la
/// bandeja de recordatorios y en los vencimientos del Inicio.
class SeverityRail extends StatelessWidget {
  const SeverityRail({
    super.key,
    required this.color,
    required this.child,
    this.width = 4,
  });

  final Color color;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: width),
        ),
      ),
      child: child,
    );
  }
}
