import 'package:flutter/material.dart';

class AppRadius {
  static const double field = 16.0;
  static const double button = 16.0;
  static const double card = 20.0;
  static const double sheet = 24.0;

  static final BorderRadius fieldRadius = BorderRadius.circular(field);
  static final BorderRadius buttonRadius = BorderRadius.circular(button);
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(sheet));
}
