import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  // Frequency bands in Hz
  final List<String> _bands = ['60', '170', '310', '600', '1K', '3K', '6K', '12K', '14K', '16K'];
  List<double> _gains = List.filled(10, 0.0); // -12 to +12 dB
  String _selectedPreset = 'Flat';

  final Map<String, List<double>> _presets = {
    'Flat':        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    'Bass Boost':  [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
    'Treble Boost':[0, 0, 0, 0, 2, 4, 5, 6, 6, 6],
    'Vocal':       [-2, 0, 2, 4, 4, 4, 2, 0, -1, -2],
    'Pop':         [1, 2, 4, 4, 2, 0, 2, 4, 4, 4],
    'Rock':        [4, 3, 2, 1, 0, 0, 1, 3, 4, 4],
    'Jazz':        [3, 2, 1, 2, -1, -1, 0, 1, 2, 3],
    'Electronic':  [4, 3, 0, -1, -2, 1, 0, 1, 3, 4],
    'Classical':   [4, 3, 2, 1, -1, 0, 1, 2, 3, 4],
    'Hip-Hop':     [4, 4, 2, 1, -1, -1, 1, 1, 2, 2],
    'Acoustic':    [3, 2, 2, 1, 1, 0, 1, 2, 2, 3],
    'Loudness':    [5, 3, 0, 0, -1, 0, 0, 0, 3, 5],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _gains = List.filled(10, 0.0);
                _selectedPreset = 'Flat';
              });
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Presets
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Presets', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.keys.length,
                    itemBuilder: (context, index) {
                      final preset = _presets.keys.elementAt(index);
                      final isSelected = _selectedPreset == preset;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPreset = preset;
                              _gains = List.from(_presets[preset]!);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.darkCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.darkElevated,
                              ),
                            ),
                            child: Text(
                              preset,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // EQ Visualizer - simple bar representation
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _gains.map((gain) {
                final normalizedHeight = ((gain + 12) / 24).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 36 * normalizedHeight + 2,
                      decoration: BoxDecoration(
                        color: gain >= 0 ? AppColors.primary : AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Band sliders
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _bands.length,
              itemBuilder: (context, index) {
                return _BandSlider(
                  frequency: _bands[index],
                  gain: _gains[index],
                  onChanged: (value) {
                    setState(() {
                      _gains[index] = value;
                      _selectedPreset = 'Custom';
                    });
                  },
                );
              },
            ),
          ),

          // Bass & Treble quick sliders
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Bass', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Slider(
                        value: _gains[0],
                        min: -12,
                        max: 12,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.darkElevated,
                        onChanged: (v) => setState(() { _gains[0] = v; _gains[1] = v * 0.8; }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Treble', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Slider(
                        value: _gains[8],
                        min: -12,
                        max: 12,
                        activeColor: AppColors.accentBlue,
                        inactiveColor: AppColors.darkElevated,
                        onChanged: (v) => setState(() { _gains[8] = v; _gains[9] = v * 0.9; }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final String frequency;
  final double gain;
  final ValueChanged<double> onChanged;

  const _BandSlider({
    required this.frequency,
    required this.gain,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${frequency}Hz',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: gain >= 0 ? AppColors.primary : AppColors.accent,
                inactiveTrackColor: AppColors.darkElevated,
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withOpacity(0.1),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: gain,
                min: -12,
                max: 12,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}',
              style: TextStyle(
                color: gain >= 0 ? AppColors.primary : AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
