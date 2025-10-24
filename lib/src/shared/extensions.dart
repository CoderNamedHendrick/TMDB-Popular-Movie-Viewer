import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension ThemeExtensions on BuildContext {
  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }

  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }
}

extension ScrollControllerX on ScrollController {
  bool get isAtEndOfList {
    if (position.axis == Axis.horizontal) return _isAtHorizontalEndOfList;
    return _isAtVerticalEndOfList;
  }

  bool get _isAtVerticalEndOfList {
    return offset >= (position.maxScrollExtent - 50) && !position.outOfRange;
  }

  bool get _isAtHorizontalEndOfList {
    return offset >= (position.maxScrollExtent - 50) &&
        !position.outOfRange &&
        position.userScrollDirection == ScrollDirection.reverse;
  }
}
