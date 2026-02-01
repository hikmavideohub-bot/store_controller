import 'package:flutter/material.dart';
import 'a2hs_stub.dart' if (dart.library.html) 'a2hs_web.dart';

abstract class A2HS {
  static Future<void> maybeShow(BuildContext context) =>
      A2HSImpl.maybeShow(context);
}
