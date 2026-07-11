import 'package:flutter/widgets.dart';

abstract final class AppDeviceProfiles {
  static const String primaryMobileDeviceName = 'Google Pixel 7';
  static const Size pixel7LogicalSize = Size(412, 915);
  static const double pixel7LogicalWidth = 412;
  static const double compactPhoneWidth = 380;

  static bool isPixel7WidthOrNarrower(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= pixel7LogicalWidth;
  }
}
