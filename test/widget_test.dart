import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/main.dart';
import 'package:manga_reader/features/auth/domain/repositories/auth_repository.dart';
import 'package:manga_reader/features/auth/domain/entities/user.dart';
import 'package:manga_reader/features/library/domain/repositories/manga_repository.dart';
import 'package:manga_reader/features/library/domain/entities/manga.dart';
import 'package:manga_reader/features/library/domain/entities/manga_details.dart';
import 'package:manga_reader/features/library/domain/entities/chapter.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login({required String email, required String password}) async {
    return const User(id: 1, name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<User> register({required String name, required String email, required String password}) async {
    return const User(id: 1, name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}

  @override
  Future<User?> getSavedUser() async => null;
}

class MockMangaRepository implements MangaRepository {
  @override
  Future<List<Manga>> fetchFeed({required int limit, required int offset}) async {
    return const [
      Manga(id: '1', title: 'Chainsaw Man', coverUrl: 'https://example.com/c1.jpg', isFavorite: false),
      Manga(id: '2', title: 'One Piece', coverUrl: 'https://example.com/c2.jpg', isFavorite: false),
      Manga(id: '3', title: 'Jujutsu Kaisen', coverUrl: 'https://example.com/c3.jpg', isFavorite: false),
    ];
  }

  @override
  Future<List<Manga>> searchManga({required String query, required int limit, required int offset}) async {
    return const [];
  }

  @override
  Future<MangaDetails> fetchMangaDetails(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorite(String id) async {}

  @override
  Future<bool> isFavorite(String id) async => false;

  @override
  Future<List<String>> fetchChapterPages(String chapterId, {String quality = 'data'}) async {
    return const [];
  }

  @override
  Future<void> updateReadingProgress(String chapterId, int pageIndex) async {}

  @override
  Future<Chapter?> fetchChapter(String chapterId) async {
    return null;
  }
}

void main() {
  testWidgets('App starts on login screen, handles login, and navigates to biblioteca', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockAuthRepository = MockAuthRepository();
    final mockMangaRepository = MockMangaRepository();

    // Build our app and trigger a frame with the mock overrides.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          mangaRepositoryProvider.overrideWithValue(mockMangaRepository),
        ],
        child: const MyApp(),
      ),
    );

    // Let the GoRouter initialize and complete initial frame transitions
    await tester.pumpAndSettle();

    // Verify that the login screen elements are present (startup & route validation)
    expect(find.text('Manga Reader'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Não tem uma conta?'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);

    // Enter login credentials to pass form validation
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pumpAndSettle();

    // Tap the 'Entrar' (Login) button to trigger navigation to home ('/')
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));

    // Wait for the transition animations and router configuration to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that we successfully navigated to the library screen (Biblioteca)
    expect(find.text('Biblioteca'), findsAtLeastNWidgets(1));

    // Verify other navigation bar items are rendered
    expect(find.text('Pesquisar'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);

    // Verify that mock content of HomeScreen is displayed properly
    expect(find.text('Chainsaw Man'), findsOneWidget);
    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('Jujutsu Kaisen'), findsOneWidget);
  });
}
