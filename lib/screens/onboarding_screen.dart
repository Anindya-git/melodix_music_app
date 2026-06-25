import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = [
    _OnboardPage(
      icon: Icons.music_note_rounded,
      color: AppColors.primary,
      title: 'Welcome to Melodix',
      subtitle: 'Your premium music experience powered by YouTube Music — millions of songs, zero subscription fees.',
    ),
    _OnboardPage(
      icon: Icons.search_rounded,
      color: const Color(0xFF4158D0),
      title: 'Search Everything',
      subtitle: 'Find any song, artist, or album instantly. Stream in crystal-clear audio quality.',
    ),
    _OnboardPage(
      icon: Icons.download_rounded,
      color: const Color(0xFFFF6B6B),
      title: 'Download & Go Offline',
      subtitle: 'Save your favorite songs locally. Listen anywhere, even without internet.',
    ),
    _OnboardPage(
      icon: Icons.equalizer_rounded,
      color: const Color(0xFF11998E),
      title: 'Studio-Grade Audio',
      subtitle: 'Customize your sound with a 10-band equalizer and preset modes for every genre.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.color.withOpacity(0.15),
                          ),
                          child: Icon(p.icon, size: 60, color: p.color),
                        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.primary : AppColors.darkElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page < _pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/home');
                    }
                  },
                  child: Text(
                    _page < _pages.length - 1 ? 'Continue' : 'Get Started',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

            if (_page < _pages.length - 1)
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}
