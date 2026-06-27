// This is a widget test for the Manga Reader frontend application startup.
//
// It validates that the application starts on the login page (initial route)
// without throwing layout or runtime exceptions, that all components render correctly,
// and that authentication transition to the home screen (Biblioteca) works correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/main.dart';

void main() {
  testWidgets('App starts on login screen, handles login, and navigates to biblioteca', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Let the GoRouter initialize and complete initial frame transitions
    await tester.pumpAndSettle();

    // Verify that the login screen elements are present (startup & route validation)
    expect(find.text('Manga Reader'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Não tem uma conta? Cadastre-se'), findsOneWidget);

    // Tap the 'Entrar' (Login) button to trigger navigation to home ('/')
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));

    // Wait for the transition animations and router configuration to complete
    await tester.pumpAndSettle();

    // Verify that we successfully navigated to the library screen (Biblioteca)
    // The library screen has AppBar and BottomNavigationBar both containing 'Biblioteca'
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
