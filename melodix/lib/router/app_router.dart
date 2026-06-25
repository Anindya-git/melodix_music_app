import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/player_screen.dart';
import '../screens/playlist_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/lyrics_screen.dart';
import '../screens/equalizer_screen.dart';
import '../screens/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/playlist/:id',
        builder: (context, state) => PlaylistScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lyrics',
        builder: (context, state) => const LyricsScreen(),
      ),
      GoRoute(
        path: '/equalizer',
        builder: (context, state) => const EqualizerScreen(),
      ),
    ],
  );
});
