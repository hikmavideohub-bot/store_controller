import 'package:flutter/foundation.dart';

class PwaService {
  static final PwaService instance = PwaService._internal();
  PwaService._internal();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);

  void init() {}
  void promptInstall() {}
}