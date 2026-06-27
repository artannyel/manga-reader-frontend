import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/isar_service.dart';
import 'features/library/domain/repositories/manga_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/library/data/repositories/manga_repository_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = await IsarService.init();
  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        mangaRepositoryProvider.overrideWith((ref) => ref.watch(mangaRepositoryImplProvider)),
        authRepositoryProvider.overrideWith((ref) => ref.watch(authRepositoryImplProvider)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme
      routerConfig: router,
    );
  }
}
