import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'models/song_model_clean.dart';
import 'models/playlist_model.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.melodix.app.channel.audio',
    androidNotificationChannelName: 'Melodix Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidNotificationIcon: 'drawable/ic_notification',
    androidStopForegroundOnPause: false,
    notificationColor: const Color(0xFF1DB954),
  );

  await Hive.initFlutter();
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(PlaylistModelAdapter());
  await Hive.openBox('songs_raw');
  await Hive.openBox('playlists');
  await Hive.openBox('settings');
  await Hive.openBox('recently_played');
  await Hive.openBox('downloads');
  await Hive.openBox('liked_songs');

  runApp(const ProviderScope(child: MelodixApp()));
}

class MelodixApp extends ConsumerWidget {
  const MelodixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Melodix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
