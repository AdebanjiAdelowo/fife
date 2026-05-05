import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile? _user;
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _programNameCtrl;
  late TextEditingController _programDurationCtrl;
  String? _sex;
  String? _bodyGoal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _user = SessionScope.of(context, listen: false).user;
    _nameCtrl = TextEditingController(text: _user?.fullName ?? '');
    _ageCtrl = TextEditingController(text: _user?.age?.toString() ?? '');
    _heightCtrl =
        TextEditingController(text: _user?.heightCm?.toString() ?? '');
    _weightCtrl =
        TextEditingController(text: _user?.weightKg?.toString() ?? '');
    _nationalityCtrl =
        TextEditingController(text: _user?.nationality ?? '');
    _locationCtrl = TextEditingController(text: _user?.location ?? '');
    _programNameCtrl =
        TextEditingController(text: _user?.currentProgramName ?? '');
    _programDurationCtrl =
        TextEditingController(text: _user?.currentProgramDuration ?? '');
    _sex = _user?.sex;
    _bodyGoal = _user?.bodyGoal;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _ageCtrl,
      _heightCtrl,
      _weightCtrl,
      _nationalityCtrl,
      _locationCtrl,
      _programNameCtrl,
      _programDurationCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _computeCompletion() {
    final fields = <String?>[
      _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text,
      _ageCtrl.text.trim().isEmpty ? null : _ageCtrl.text,
      _heightCtrl.text.trim().isEmpty ? null : _heightCtrl.text,
      _weightCtrl.text.trim().isEmpty ? null : _weightCtrl.text,
      _nationalityCtrl.text.trim().isEmpty ? null : _nationalityCtrl.text,
      _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text,
      _sex,
      _bodyGoal,
      _programNameCtrl.text.trim().isEmpty ? null : _programNameCtrl.text,
      _user?.profilePhotoPath,
    ];
    return fields.where((f) => f != null && f.toString().isNotEmpty).length;
  }

  Future<void> _save() async {
    final session = SessionScope.of(context, listen: false);
    final current = session.user;
    if (current == null) return;
    setState(() => _saving = true);
    try {
      final updated = UserProfile(
        id: current.id,
        email: current.email,
        passwordHash: current.passwordHash,
        programCode: current.programCode,
        fullName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        profilePhotoPath: _user?.profilePhotoPath,
        age: int.tryParse(_ageCtrl.text.trim()),
        heightCm: double.tryParse(_heightCtrl.text.trim()),
        sex: _sex,
        weightKg: double.tryParse(_weightCtrl.text.trim()),
        nationality: _nationalityCtrl.text.trim().isEmpty
            ? null
            : _nationalityCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        currentProgramName: _programNameCtrl.text.trim().isEmpty
            ? null
            : _programNameCtrl.text.trim(),
        currentProgramDuration: _programDurationCtrl.text.trim().isEmpty
            ? null
            : _programDurationCtrl.text.trim(),
        bodyGoal: _bodyGoal,
        profileCompletion: _computeCompletion(),
        createdAt: current.createdAt,
      );
      await session.updateProfile(updated);
      setState(() => _user = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || _user == null) return;
    final updated = UserProfile(
      id: _user!.id,
      email: _user!.email,
      passwordHash: _user!.passwordHash,
      programCode: _user!.programCode,
      fullName: _user!.fullName,
      profilePhotoPath: picked.path,
      age: _user!.age,
      heightCm: _user!.heightCm,
      sex: _user!.sex,
      weightKg: _user!.weightKg,
      nationality: _user!.nationality,
      location: _user!.location,
      currentProgramName: _user!.currentProgramName,
      currentProgramDuration: _user!.currentProgramDuration,
      bodyGoal: _user!.bodyGoal,
      profileCompletion: _user!.profileCompletion,
      createdAt: _user!.createdAt,
    );
    await SessionScope.of(context, listen: false).updateProfile(updated);
    setState(() => _user = updated);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final bmi = user?.bmi;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            physics: const BouncingScrollPhysics(),
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
                  const Spacer(),
                  const SizedBox(width: 38),
                ],
              ),
              const SizedBox(height: 4),
              Text('My Fit Profile', style: AppTextStyles.displayLarge),
              const SizedBox(height: 4),
              Text(
                'Complete your profile to unlock projections and recommended programs.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              FifeCard(
                glow: true,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _changeAvatar,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceMuted,
                          border: Border.all(
                              color: AppColors.limeAccent, width: 1.4),
                          image: user?.profilePhotoPath == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(
                                      File(user!.profilePhotoPath!)),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        alignment: Alignment.center,
                        child: user?.profilePhotoPath == null
                            ? const Icon(Icons.person_rounded,
                                color: AppColors.textSecondary)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Coach Fife · FIFER',
                            style: AppTextStyles.headingMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(user?.email ?? '',
                              style: AppTextStyles.bodySmall),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.limeAccent
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Profile Style: ${_styleLabel()}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.limeAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FifeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Initial Body Data',
                      subtitle: 'Used to derive your BMI and goals',
                      icon: Icons.fact_check_rounded,
                    ),
                    const SizedBox(height: 14),
                    _field('Full Name', _nameCtrl),
                    Row(children: [
                      Expanded(child: _field('Age', _ageCtrl,
                          keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Height (cm)', _heightCtrl,
                          keyboardType: TextInputType.number)),
                    ]),
                    Row(children: [
                      Expanded(child: _field('Weight (kg)', _weightCtrl,
                          keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _dropdown(
                        label: 'Sex',
                        value: _sex,
                        options: const ['Female', 'Male', 'Non-binary'],
                        onChanged: (v) => setState(() => _sex = v),
                      )),
                    ]),
                    Row(children: [
                      Expanded(child: _field('Nationality', _nationalityCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Location', _locationCtrl)),
                    ]),
                    Row(children: [
                      Expanded(
                        child: _dropdown(
                          label: 'Body Goal',
                          value: _bodyGoal,
                          options: const [
                            'Lose Weight',
                            'Build Muscle',
                            'Maintain',
                            'Recomposition',
                          ],
                          onChanged: (v) => setState(() => _bodyGoal = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.limeAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.limeAccent
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BMI',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.limeAccent,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                bmi == null
                                    ? '—'
                                    : bmi.toStringAsFixed(1),
                                style: AppTextStyles.headingLarge.copyWith(
                                  color: AppColors.limeAccent,
                                ),
                              ),
                              Text(
                                user?.bmiCategory ?? 'Add height + weight',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FifeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Current Program',
                      subtitle: 'What Coach Fife is running for you',
                      icon: Icons.flag_rounded,
                    ),
                    const SizedBox(height: 14),
                    _field('Program Name', _programNameCtrl),
                    _field('Duration', _programDurationCtrl),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FifeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'BMI Implications',
                      subtitle: 'Recommended programs for your goal',
                      icon: Icons.health_and_safety_rounded,
                    ),
                    const SizedBox(height: 14),
                    _RecommendedRow(
                      title: 'Strength Training',
                      subtitle: '3 sessions / week · 4 weeks',
                    ),
                    const SizedBox(height: 8),
                    _RecommendedRow(
                      title: 'Endurance Building',
                      subtitle: '5 sessions / week · 6 weeks',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlowButton(
                label: _saving ? 'Saving…' : 'Save Profile',
                icon: Icons.check_rounded,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _styleLabel() {
    final c = _computeCompletion();
    if (c <= 3) return 'Starter';
    if (c <= 6) return 'Medium';
    return 'Pro';
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: label),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: options.contains(value) ? value : null,
            decoration: const InputDecoration(),
            dropdownColor: AppColors.surfaceElevated,
            iconEnabledColor: AppColors.limeAccent,
            style: AppTextStyles.bodyLarge,
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.limeAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Start',
              style: AppTextStyles.button.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
