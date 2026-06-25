import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 140),
        children: [
          _SectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Use dark theme', style: TextStyle(color: AppColors.textSecondary)),
            value: themeMode == ThemeMode.dark,
            activeColor: AppColors.primary,
            onChanged: (v) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const Divider(color: AppColors.darkSurface),

          _SectionHeader('Audio'),
          _SettingTile(
            icon: Icons.equalizer_rounded,
            title: 'Equalizer',
            subtitle: 'Customize audio frequencies',
            onTap: () => Navigator.pushNamed(context, '/equalizer'),
          ),
          _SettingTile(
            icon: Icons.high_quality_rounded,
            title: 'Streaming Quality',
            subtitle: 'High (320kbps)',
            onTap: () => _showQualityDialog(context),
          ),
          _SettingTile(
            icon: Icons.download_rounded,
            title: 'Download Quality',
            subtitle: 'Best Available',
            onTap: () {},
          ),

          const Divider(color: AppColors.darkSurface),
          _SectionHeader('Playback'),
          _SettingTile(
            icon: Icons.timer_rounded,
            title: 'Crossfade',
            subtitle: '3 seconds',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.volume_up_rounded,
            title: 'Normalize Volume',
            subtitle: 'Keep volume levels consistent',
            onTap: () {},
          ),

          const Divider(color: AppColors.darkSurface),
          _SectionHeader('Cache & Storage'),
          _SettingTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {},
          ),

          const Divider(color: AppColors.darkSurface),
          _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
            title: const Text('Version', style: TextStyle(color: Colors.white)),
            trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.code_rounded, color: AppColors.textSecondary),
            title: const Text('Open Source Licenses', style: TextStyle(color: Colors.white)),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Streaming Quality', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final q in ['Low (96kbps)', 'Normal (160kbps)', 'High (320kbps)', 'Very High (Lossless)'])
              ListTile(
                title: Text(q, style: const TextStyle(color: Colors.white)),
                trailing: q.contains('320') ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2)),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
