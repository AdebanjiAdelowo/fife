import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/workout_report.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // Workout form
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _setsDoneCtrl = TextEditingController();
  final _grandTotalCtrl = TextEditingController();
  final _howCtrl = TextEditingController();
  final _difficultCtrl = TextEditingController();
  final _enjoyCtrl = TextEditingController();
  final _painCtrl = TextEditingController();
  String? _sweatfiePath;
  TimeOfDay? _time;
  DateTime _date = DateTime.now();

  WorkoutReport? _summary;
  late Future<List<DietGalleryEntry>> _dietFuture;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _dietFuture = _loadDiet();
  }

  Future<List<DietGalleryEntry>> _loadDiet() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return const [];
    return LocalStorage.instance.dietGallery(user.id);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final ctrl in [
      _nameCtrl,
      _typeCtrl,
      _teamCtrl,
      _setsDoneCtrl,
      _grandTotalCtrl,
      _howCtrl,
      _difficultCtrl,
      _enjoyCtrl,
      _painCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _attachSweatfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _sweatfiePath = picked.path);
  }

  Future<void> _submitReport() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add your name to log this report.')),
      );
      return;
    }
    final report = WorkoutReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      recordedAt: DateTime.now(),
      name: _nameCtrl.text.trim(),
      workoutType: _typeCtrl.text.trim(),
      team: _teamCtrl.text.trim(),
      setsDone: int.tryParse(_setsDoneCtrl.text.trim()) ?? 0,
      grandTotalSets: int.tryParse(_grandTotalCtrl.text.trim()) ?? 0,
      howWasWorkout: _howCtrl.text.trim(),
      difficultExercise: _difficultCtrl.text.trim(),
      enjoyedExercise: _enjoyCtrl.text.trim(),
      painOrStrain: _painCtrl.text.trim(),
      sweatfiePath: _sweatfiePath,
      time: _time?.format(context),
    );
    await LocalStorage.instance.saveWorkoutReport(user.id, report);
    setState(() {
      _summary = report;
    });
  }

  Future<void> _addDietPhoto() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final entry = DietGalleryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      recordedAt: DateTime.now(),
      imagePath: picked.path,
    );
    await LocalStorage.instance.saveDietGalleryEntry(user.id, entry);
    setState(() => _dietFuture = _loadDiet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Text('Check In', style: AppTextStyles.displayLarge),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: AppColors.limeAccent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    labelColor: AppColors.textOnAccent,
                    unselectedLabelColor: AppColors.textSecondary,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    labelStyle:
                        AppTextStyles.button.copyWith(fontSize: 14),
                    tabs: const [
                      Tab(text: 'Workout Report'),
                      Tab(text: 'Diet Gallery'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildWorkoutTab(context),
                    _buildDietTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      physics: const BouncingScrollPhysics(),
      children: [
        FifeCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Fill Workout Report',
                subtitle: 'Sincere accountability · electric lime energy',
                icon: Icons.fitness_center_rounded,
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _attachSweatfie,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    image: _sweatfiePath == null
                        ? null
                        : DecorationImage(
                            image: FileImage(File(_sweatfiePath!)),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: _sweatfiePath != null
                      ? null
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_a_photo_rounded,
                                color: AppColors.limeAccent),
                            const SizedBox(height: 6),
                            Text('Attach Sweatfie',
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _field('Name', _nameCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Workout Type', _typeCtrl)),
              ]),
              Row(children: [
                Expanded(
                  child: _DateTimeField(
                    label: 'Date',
                    icon: Icons.calendar_month_rounded,
                    text: DateFormat.yMd().format(_date),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                        initialDate: _date,
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimeField(
                    label: 'Time',
                    icon: Icons.schedule_rounded,
                    text: _time?.format(context) ?? 'Pick',
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _time = picked);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(child: _field('Team', _teamCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Sets Done', _setsDoneCtrl,
                    keyboardType: TextInputType.number)),
              ]),
              _field('Grand Total Sets Done', _grandTotalCtrl,
                  keyboardType: TextInputType.number),
              _field('How was the workout?', _howCtrl),
              _field('What did you find difficult?', _difficultCtrl),
              _field('What did you enjoy most?', _enjoyCtrl),
              _field('Pain or strain? Where?', _painCtrl),
              const SizedBox(height: 4),
              GlowButton(
                label: 'Submit Workout',
                icon: Icons.send_rounded,
                onPressed: _submitReport,
              ),
            ],
          ),
        ),
        if (_summary != null) ...[
          const SizedBox(height: 12),
          FifeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Workout Report Summary',
                  subtitle: 'Share to WhatsApp · Tiktok · Instagram',
                  icon: Icons.summarize_rounded,
                ),
                const SizedBox(height: 14),
                _summaryRow('Athlete', _summary!.name),
                _summaryRow('Type', _summary!.workoutType),
                _summaryRow('Sets',
                    '${_summary!.setsDone} / ${_summary!.grandTotalSets}'),
                _summaryRow('Felt', _summary!.howWasWorkout),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: GlowButton(
                      label: 'Share',
                      icon: Icons.ios_share_rounded,
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(text: _formatShareText(_summary!)),
                        );
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDietTab(BuildContext context) {
    return FutureBuilder<List<DietGalleryEntry>>(
      future: _dietFuture,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            FifeCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Diet Gallery',
                    subtitle: 'Build your weekly diet streak',
                    icon: Icons.restaurant_menu_rounded,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Add a quick photo of every meal — Coach Fife uses it '
                    'to spot patterns and keep your streak alive.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  GlowButton(
                    label: 'Add Diet Photo',
                    icon: Icons.add_photo_alternate_rounded,
                    onPressed: _addDietPhoto,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.local_dining_rounded,
                        color: AppColors.limeAccent, size: 48),
                    const SizedBox(height: 12),
                    Text('No streak yet — let\'s plate up.',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entries.length,
                itemBuilder: (_, i) {
                  final e = entries[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(e.imagePath), fit: BoxFit.cover),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat.MMMd().format(e.recordedAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
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
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(k.toUpperCase(),
              style: AppTextStyles.label),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v.isEmpty ? '—' : v,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  String _formatShareText(WorkoutReport r) {
    return 'FiFe Check-In · ${r.name}\n'
        '${r.workoutType.isEmpty ? "Workout" : r.workoutType} · '
        '${r.setsDone}/${r.grandTotalSets} sets\n'
        '${r.howWasWorkout}\n#FitAndFeline';
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.limeAccent),
                  const SizedBox(width: 8),
                  Text(text, style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
