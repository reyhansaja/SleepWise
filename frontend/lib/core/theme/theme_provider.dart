import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
