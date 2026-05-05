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
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _programCodeCtrl = TextEditingController();
  bool _agreed = true;
  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _programCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms and Conditions.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SessionScope.of(context).register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        programCode: _programCodeCtrl.text.trim(),
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
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.limeAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _Label('Email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Email is required.';
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Enter a valid email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _Label('Create Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordCtrl,
                          textInputAction: TextInputAction.next,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: 'Create your password',
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
                          validator: (value) {
                            if ((value ?? '').length < 6) {
                              return 'At least 6 characters please.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreed,
                              activeColor: AppColors.limeAccent,
                              checkColor: AppColors.textOnAccent,
                              onChanged: (v) =>
                                  setState(() => _agreed = v ?? false),
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms and Conditions',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _Label('Program Code (optional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _programCodeCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Enter program code',
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        GlowButton(
                          label:
                              _loading ? 'Creating…' : 'Create Account',
                          onPressed: _loading ? null : _submit,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: const Text('Login'),
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label,
    );
  }
}
