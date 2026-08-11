import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

void hapticLight(WidgetRef ref) {
  if (ref.read(hapticEnabledProvider)) {
    HapticFeedback.lightImpact();
  }
}
