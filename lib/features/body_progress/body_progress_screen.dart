import 'dart:io';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/body_measurement.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';
import 'body_avatar_painter.dart';

class BodyProgressScreen extends StatefulWidget {
  const BodyProgressScreen({super.key});

  @override
  State<BodyProgressScreen> createState() => _BodyProgressScreenState();
}

class _BodyProgressScreenState extends State<BodyProgressScreen> {
  final _bustCtrl = TextEditingController();
  final _waistUnderCtrl = TextEditingController();
  final _waistBellyCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String? _frontPhoto, _leftPhoto, _rightPhoto, _backPhoto;
  bool _saving = false;
  late Future<List<BodyMeasurement>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<BodyMeasurement>> _load() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return const [];
    return LocalStorage.instance.measurements(user.id);
  }

  @override
  void dispose() {
    _bustCtrl.dispose();
    _waistUnderCtrl.dispose();
    _waistBellyCtrl.dispose();
    _hipsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(String slot) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.limeAccent),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.limeAccent),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() {
      switch (slot) {
        case 'front':
          _frontPhoto = picked.path;
          break;
        case 'left':
          _leftPhoto = picked.path;
          break;
        case 'right':
          _rightPhoto = picked.path;
          break;
        case 'back':
          _backPhoto = picked.path;
          break;
      }
    });
  }

  Future<void> _saveMeasurement() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final bust = double.tryParse(_bustCtrl.text.trim()) ?? 0;
      final waistU = double.tryParse(_waistUnderCtrl.text.trim()) ?? 0;
      final waistB = double.tryParse(_waistBellyCtrl.text.trim()) ?? 0;
      final hips = double.tryParse(_hipsCtrl.text.trim()) ?? 0;
      final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0;
      if (bust == 0 || waistB == 0 || hips == 0 || weight == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all metrics.')),
        );
        return;
      }
      final upper = bust - waistU;
      final lower = hips - waistB;
      final m = BodyMeasurement(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        recordedAt: DateTime.now(),
        bustInches: bust,
        waistUnderbustInches: waistU,
        waistBellyButtonInches: waistB,
        hipsInches: hips,
        weightKg: weight,
        upperBodyCurve: upper,
        lowerBodyCurve: lower,
        performance:
            ((upper + lower).abs() * 4).clamp(0, 100).toDouble(),
        frontPhotoPath: _frontPhoto,
        leftPhotoPath: _leftPhoto,
        rightPhotoPath: _rightPhoto,
        backPhotoPath: _backPhoto,
      );
      await LocalStorage.instance.saveMeasurement(user.id, m);
      _bustCtrl.clear();
      _waistUnderCtrl.clear();
      _waistBellyCtrl.clear();
      _hipsCtrl.clear();
      _weightCtrl.clear();
      setState(() {
        _future = _load();
        _frontPhoto = _leftPhoto = _rightPhoto = _backPhoto = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Body progress saved.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: FutureBuilder<List<BodyMeasurement>>(
            future: _future,
            builder: (context, snapshot) {
              final measurements = snapshot.data ?? const [];
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18),
                          ),
                          const Spacer(),
                          const FifeLogo(size: 24),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.ios_share_rounded,
                                size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text('Body Progress Map',
                          style: AppTextStyles.displayLarge),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _FillBodyProgressCard(
                        bustCtrl: _bustCtrl,
                        waistUnderCtrl: _waistUnderCtrl,
                        waistBellyCtrl: _waistBellyCtrl,
                        hipsCtrl: _hipsCtrl,
                        weightCtrl: _weightCtrl,
                        saving: _saving,
                        onSave: _saveMeasurement,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _BodyProgressCamCard(
                        front: _frontPhoto,
                        left: _leftPhoto,
                        right: _rightPhoto,
                        back: _backPhoto,
                        onTap: _pickPhoto,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _MappingTable(measurements: measurements),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _MappingGraph(measurements: measurements),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _MappingAvatar(measurements: measurements),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _BodyCamCompare(measurements: measurements),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _GeneralInfoCard(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FillBodyProgressCard extends StatelessWidget {
  const _FillBodyProgressCard({
    required this.bustCtrl,
    required this.waistUnderCtrl,
    required this.waistBellyCtrl,
    required this.hipsCtrl,
    required this.weightCtrl,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController bustCtrl;
  final TextEditingController waistUnderCtrl;
  final TextEditingController waistBellyCtrl;
  final TextEditingController hipsCtrl;
  final TextEditingController weightCtrl;
  final bool saving;
  final VoidCallback onSave;

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.limeAccent, size: 16),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Fill Body Progress Map',
            subtitle: 'All measurements in inches · weight in kg',
            icon: Icons.straighten_rounded,
          ),
          const SizedBox(height: 18),
          _field(
              ctrl: bustCtrl,
              label: 'BUST',
              hint: 'e.g. 36.5',
              icon: Icons.accessibility_new_rounded),
          _field(
              ctrl: waistUnderCtrl,
              label: 'WAIST · UNDERBUST',
              hint: 'e.g. 30.0',
              icon: Icons.straighten_rounded),
          _field(
              ctrl: waistBellyCtrl,
              label: 'WAIST · AROUND BELLY BUTTON',
              hint: 'e.g. 32.0',
              icon: Icons.straighten_rounded),
          _field(
              ctrl: hipsCtrl,
              label: 'HIPS',
              hint: 'e.g. 40.0',
              icon: Icons.crop_portrait_rounded),
          _field(
              ctrl: weightCtrl,
              label: 'WEIGHT (KG)',
              hint: 'e.g. 70',
              icon: Icons.monitor_weight_rounded),
          GlowButton(
            label: saving ? 'Saving…' : 'Save Body Map',
            icon: Icons.save_rounded,
            onPressed: saving ? null : onSave,
          ),
        ],
      ),
    );
  }
}

class _BodyProgressCamCard extends StatelessWidget {
  const _BodyProgressCamCard({
    required this.front,
    required this.left,
    required this.right,
    required this.back,
    required this.onTap,
  });

  final String? front, left, right, back;
  final void Function(String slot) onTap;

  Widget _slot(String label, String slot, String? path) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(slot),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: path == null
                  ? AppColors.border
                  : AppColors.limeAccent.withValues(alpha: 0.5),
            ),
            image: path == null
                ? null
                : DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Body Progress Cam',
            subtitle:
                'Wear a light body fit. Stand at ease. Front, sides, back.',
            icon: Icons.photo_camera_rounded,
          ),
          const SizedBox(height: 16),
          Row(children: [
            _slot('Front', 'front', front),
            _slot('Left', 'left', left),
            _slot('Right', 'right', right),
            _slot('Back', 'back', back),
          ]),
          const SizedBox(height: 12),
          Text(
            'Tap any slot to upload from gallery or take a fresh photo.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MappingTable extends StatelessWidget {
  const _MappingTable({required this.measurements});
  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Mapping Table',
            subtitle: 'Every entry, every change',
            icon: Icons.table_rows_rounded,
          ),
          const SizedBox(height: 12),
          if (measurements.isEmpty)
            Text(
              'No entries yet. Save a body map above to populate this table.',
              style: AppTextStyles.bodyMedium,
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowColor: const WidgetStatePropertyAll(
                    AppColors.surfaceMuted),
                headingTextStyle: AppTextStyles.label,
                dataTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Bust')),
                  DataColumn(label: Text('W·Under')),
                  DataColumn(label: Text('W·Belly')),
                  DataColumn(label: Text('Hips')),
                  DataColumn(label: Text('Weight')),
                  DataColumn(label: Text('Upper')),
                  DataColumn(label: Text('Lower')),
                  DataColumn(label: Text('Perf')),
                ],
                rows: [
                  for (final m in measurements.reversed)
                    DataRow(cells: [
                      DataCell(Text(DateFormat.MMMd().format(m.recordedAt))),
                      DataCell(Text(m.bustInches.toStringAsFixed(1))),
                      DataCell(Text(m.waistUnderbustInches.toStringAsFixed(1))),
                      DataCell(Text(
                          m.waistBellyButtonInches.toStringAsFixed(1))),
                      DataCell(Text(m.hipsInches.toStringAsFixed(1))),
                      DataCell(Text('${m.weightKg.toStringAsFixed(1)}kg')),
                      DataCell(Text(m.upperBodyCurve.toStringAsFixed(1))),
                      DataCell(Text(m.lowerBodyCurve.toStringAsFixed(1))),
                      DataCell(Text('${m.performance.toStringAsFixed(0)}%')),
                    ]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MappingGraph extends StatelessWidget {
  const _MappingGraph({required this.measurements});
  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    if (measurements.length < 2) {
      return FifeCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Mapping Graph',
              subtitle: 'Curve projection · weight stack',
              icon: Icons.timeline_rounded,
            ),
            const SizedBox(height: 12),
            Text(
              'Need at least two entries to project your curve. Keep going.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    final sorted = [...measurements]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final minX = 0.0;
    final maxX = (sorted.length - 1).toDouble();
    final maxY = math.max(
      sorted.map((m) => m.upperBodyCurve.abs()).fold<double>(0, math.max),
      sorted.map((m) => m.lowerBodyCurve.abs()).fold<double>(0, math.max),
    );

    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Mapping Graph',
            subtitle: 'Upper · Lower body curve',
            icon: Icons.timeline_rounded,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: maxY + 4,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.limeAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    spots: [
                      for (int i = 0; i < sorted.length; i++)
                        FlSpot(i.toDouble(), sorted[i].upperBodyCurve),
                    ],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.avatarGoal,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.avatarGoal.withValues(alpha: 0.18),
                    ),
                    spots: [
                      for (int i = 0; i < sorted.length; i++)
                        FlSpot(i.toDouble(), sorted[i].lowerBodyCurve),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: const [
            _LegendDot(color: AppColors.limeAccent, label: 'Upper Curve'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.avatarGoal, label: 'Lower Curve'),
          ]),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(4),
      )),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.bodySmall),
    ]);
  }
}

class _MappingAvatar extends StatelessWidget {
  const _MappingAvatar({required this.measurements});
  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final first = measurements.isNotEmpty ? measurements.first : null;
    final current = measurements.isNotEmpty ? measurements.last : null;
    BodyMeasurement? goal;
    if (first != null) {
      // Goal silhouette = halve the waist gain, retain bust/hips.
      goal = BodyMeasurement(
        id: 'goal',
        recordedAt: first.recordedAt,
        bustInches: first.bustInches,
        waistUnderbustInches: first.waistUnderbustInches - 1,
        waistBellyButtonInches: first.waistBellyButtonInches - 2,
        hipsInches: first.hipsInches,
        weightKg: first.weightKg - 4,
      );
    }

    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Mapping Avatar',
            subtitle: 'First · Goal · Current silhouettes',
            icon: Icons.accessibility_new_rounded,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: BodyAvatarPainter(
                first: first,
                goal: goal,
                current: current,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: const [
            _LegendDot(color: AppColors.avatarFirst, label: 'First'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.avatarGoal, label: 'Goal'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.avatarCurrent, label: 'Current'),
          ]),
        ],
      ),
    );
  }
}

class _BodyCamCompare extends StatelessWidget {
  const _BodyCamCompare({required this.measurements});
  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final first = measurements.isNotEmpty ? measurements.first : null;
    final latest = measurements.isNotEmpty ? measurements.last : null;
    final firstPhoto = first?.frontPhotoPath;
    final latestPhoto = latest?.frontPhotoPath;

    Widget tile(String label, String? path) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              image: path == null
                  ? null
                  : DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                    ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label, style: AppTextStyles.bodySmall),
            ),
          ),
        );

    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Body Cam Compare',
            subtitle: 'First photo vs current photo',
            icon: Icons.compare_rounded,
          ),
          const SizedBox(height: 12),
          Row(children: [
            tile('First', firstPhoto),
            tile('Current', latestPhoto),
          ]),
        ],
      ),
    );
  }
}

class _GeneralInfoCard extends StatelessWidget {
  const _GeneralInfoCard();
  @override
  Widget build(BuildContext context) {
    return FifeCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              color: AppColors.limeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Small progress adds up over time to make Big Progress. Be '
              'kind to yourself. Stick to your program. Reach out to '
              'Fit & Feline on WhatsApp for any concerns.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
