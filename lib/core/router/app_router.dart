import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/library/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/details/presentation/screens/manga_details_screen.dart';
import '../../features/reader/presentation/screens/chapter_reader_screen.dart';
import '../../features/downloads/presentation/screens/downloads_screen.dart';
import '../../features/downloads/presentation/screens/offline_screen.dart';

import 'package:isar/isar.dart';
import '../services/connectivity_service.dart';
import '../services/isar_service.dart';
import '../../features/library/data/models/chapter_entity.dart';
import '../../features/library/domain/entities/chapter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
    _ref.listen(connectivityProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: routerNotifier,
    redirect: (context, state) async {
      final connectivity = ref.read(connectivityProvider);
      final isOffline = connectivity == ConnectivityStatus.offline;
      final location = state.matchedLocation;

      if (isOffline) {
        if (location == '/downloads' || location == '/offline') {
          return null;
        }
        if (location == '/manga/:id/chapter/:chapterId') {
          final chapterId = state.pathParameters['chapterId'];
          if (chapterId != null) {
            final isarService = ref.read(isarServiceProvider);
            final chapter = await isarService.isar.chapterEntitys
                .filter()
                .mangaDexIdEqualTo(chapterId)
                .findFirst();
            if (chapter != null && chapter.downloadStatus == DownloadStatus.downloaded) {
              return null;
            }
          }
        }
        return '/offline';
      }

      if (location == '/offline') {
        return '/';
      }

      final authState = ref.read(authProvider);

      // Do not redirect while checking initial auth status
      if (authState is AuthInitial) {
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      final isLoggingIn = location == '/login';
      final isRegistering = location == '/register';

      if (!isAuthenticated) {
        // If not authenticated and trying to access a private route
        if (!isLoggingIn && !isRegistering) {
          return '/login';
        }
      } else {
        // If authenticated and trying to access login/register
        if (isLoggingIn || isRegistering) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      
      // Bottom navigation shell using StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (context, state) => const DownloadsScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Secondary/Detail Screens that display above the bottom bar
      GoRoute(
        path: '/manga/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MangaDetailsScreen(mangaId: id);
        },
      ),
      GoRoute(
        path: '/manga/:id/chapter/:chapterId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final chapterId = state.pathParameters['chapterId'] ?? '';
          return ChapterReaderScreen(mangaId: id, chapterId: chapterId);
        },
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_for_offline),
            label: 'Downloads',
          ),
        ],
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
