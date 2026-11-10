import 'package:flutter/widgets.dart';

/// Radios de borde compartidos.
abstract final class AppRadii {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);
  static const pill = Radius.circular(999);

  static const smAll = BorderRadius.all(sm);
  static const mdAll = BorderRadius.all(md);
  static const lgAll = BorderRadius.all(lg);
  static const xlAll = BorderRadius.all(xl);
  static const pillAll = BorderRadius.all(pill);
}
