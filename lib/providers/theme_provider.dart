import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

final toggleThemeProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final currentTheme = ref.watch(themeProvider);
  final newTheme = !currentTheme;

  await prefs.setBool('isDarkMode', newTheme);
  ref.read(themeProvider.notifier).state = newTheme;

  return newTheme;
});
