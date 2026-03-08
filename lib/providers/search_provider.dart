import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final clearSearchProvider = Provider<void>((ref) {
  ref.read(searchQueryProvider.notifier).state = '';
});
