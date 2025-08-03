import 'package:flutter/widgets.dart';

import 'colours.dart';

abstract class TextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colours.primaryText,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colours.primaryText,
    height: 1.4,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Colours.primaryText,
    height: 1.4,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colours.secondaryText,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colours.primaryText,
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colours.background,
    height: 1.5,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colours.primaryText,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colours.primaryBlue,
    decoration: TextDecoration.underline,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colours.secondaryText,
    height: 1.5,
  );
}
