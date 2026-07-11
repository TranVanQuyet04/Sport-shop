import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/core/constants/device_profiles.dart';

void usePixel7TestView(WidgetTester tester) {
  tester.view.physicalSize = AppDeviceProfiles.pixel7LogicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
