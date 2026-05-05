import 'package:flutter/material.dart';

import '../../core/state/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';
import '../dashboard/dashboard_screen.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SessionScope.of(context).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on SessionException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                    ),
                    const Spacer(),
                    const FifeLogo(size: 24),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 12),
                FifeCard(
                  glow: true,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: FifeLogo(size: 64, showWordmark: false),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.limeAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coach Fife missed you. Let\'s pick up where you '
                          'left off.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        Text('EMAIL', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                          validator: (v) =>
                              (v ?? '').contains('@') ? null : 'Email required',
                        ),
                        const SizedBox(height: 16),
                        Text('PASSWORD', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                          ),
                          validator: (v) =>
                              (v ?? '').isEmpty ? 'Password required' : null,
                        ),
                        const SizedBox(height: 24),
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.danger),
                          ),
                          const SizedBox(height: 12),
                        ],
                        GlowButton(
                          label: _loading ? 'Logging In…' : 'Log In',
                          onPressed: _loading ? null : _submit,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateAccountScreen(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyMedium,
                                children: [
                                  const TextSpan(text: 'New here? '),
                                  TextSpan(
                                    text: 'Create Account',
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
