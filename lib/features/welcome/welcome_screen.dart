import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../auth/create_account_screen.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const FifeLogo(size: 28),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroIllustration(),
                        const SizedBox(height: 28),
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.displayLarge,
                            children: const [
                              TextSpan(
                                text: 'Fitness ',
                                style: TextStyle(color: AppColors.limeAccent),
                              ),
                              TextSpan(text: 'at Your Fingertips'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your AI Coach Fife is ready to track every inch, '
                          'celebrate every win, and push you home.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '770+ bodies transformed. Zero gym. Zero excuses. '
                          'Just real results in your pocket.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        GlowButton(
                          label: 'Start Your Journey',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateAccountScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyMedium,
                                children: [
                                  const TextSpan(text: 'Already a FIFER?  '),
                                  TextSpan(
                                    text: 'Log In',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.limeAccent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1E23), Color(0xFF0A0B0D)],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55C8F751),
            blurRadius: 40,
            spreadRadius: -20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt,
                      color: AppColors.limeAccent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'AI Coach Fife · Online',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Center(
            child: FifeLogo(size: 92, showWordmark: false),
          ),
          Positioned(
            bottom: 22,
            left: 22,
            right: 22,
            child: Row(
              children: [
                _Stat(label: 'Programs', value: '24'),
                SizedBox(width: 12),
                _Stat(label: 'Coaches', value: '07'),
                SizedBox(width: 12),
                _Stat(label: 'Streaks', value: '∞'),
              ].map((w) => Expanded(child: w)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.limeAccent)),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
