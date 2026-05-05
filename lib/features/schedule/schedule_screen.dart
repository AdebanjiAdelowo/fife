import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/schedule_task.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/session_scope.dart';
import '../../widgets/status_chip.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _programCodeCtrl = TextEditingController();
  late Future<_ScheduleSnapshot> _future;
  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ScheduleSnapshot> _load() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return _ScheduleSnapshot([], const []);
    final today = await LocalStorage.instance
        .tasksForDate(user.id, _todayKey);
    final history =
        await LocalStorage.instance.scheduleHistoryDates(user.id);
    return _ScheduleSnapshot(today, history);
  }

  Future<void> _toggleStatus(ScheduleTask task) async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return;
    final next = switch (task.status) {
      TaskStatus.pending => TaskStatus.done,
      TaskStatus.done => TaskStatus.failed,
      TaskStatus.failed => TaskStatus.pending,
    };
    task.status = next;
    final snapshot = await _future;
    await LocalStorage.instance
        .saveTasksForDate(user.id, _todayKey, snapshot.today);
    setState(() => _future = _load());
  }

  @override
  void dispose() {
    _programCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        showSideGlow: false,
        child: SafeArea(
          child: FutureBuilder<_ScheduleSnapshot>(
            future: _future,
            builder: (context, snapshot) {
              final data = snapshot.data ?? _ScheduleSnapshot([], const []);
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
                          const SizedBox(width: 38),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Text('My Fit Schedule',
                          style: AppTextStyles.displayLarge),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Text(
                        DateFormat('EEEE · MMMM d').format(DateTime.now()),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _AutoScheduleCard(ctrl: _programCodeCtrl),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: _TodaysScheduleCard(
                        tasks: data.today,
                        onToggle: _toggleStatus,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: _TaskRecordsCard(history: data.history),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleSnapshot {
  _ScheduleSnapshot(this.today, this.history);
  final List<ScheduleTask> today;
  final List<DateTime> history;
}

class _AutoScheduleCard extends StatelessWidget {
  const _AutoScheduleCard({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Automatic Schedule',
            subtitle: 'Drop a program code to auto-fill your week',
            icon: Icons.qr_code_2_rounded,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: 'Enter your program code',
              suffixIcon: IconButton(
                icon: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.limeAccent),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ctrl.text.trim().isEmpty
                          ? 'Coach Fife: drop a program code first.'
                          : 'Coach Fife will sync ${ctrl.text.trim()} '
                              'on your next session.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysScheduleCard extends StatelessWidget {
  const _TodaysScheduleCard({
    required this.tasks,
    required this.onToggle,
  });

  final List<ScheduleTask> tasks;
  final void Function(ScheduleTask task) onToggle;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Today's Schedule",
            subtitle: 'GET IT DONE · STAY ACCOUNTABLE',
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                flex: 5,
                child: Text('TASK',
                    style: AppTextStyles.label)),
            Expanded(
                flex: 3,
                child: Text('DEADLINE',
                    style: AppTextStyles.label)),
            Expanded(
                flex: 2,
                child: Text('STATUS',
                    style: AppTextStyles.label,
                    textAlign: TextAlign.right)),
          ]),
          const SizedBox(height: 6),
          const Divider(),
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.label,
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700)),
                        Text(task.description,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(task.deadline,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => onToggle(task),
                        child: StatusChip(
                          status: switch (task.status) {
                            TaskStatus.pending => FifeStatus.pending,
                            TaskStatus.done => FifeStatus.done,
                            TaskStatus.failed => FifeStatus.failed,
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Status auto-resets every 24 hours.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TaskRecordsCard extends StatelessWidget {
  const _TaskRecordsCard({required this.history});
  final List<DateTime> history;

  @override
  Widget build(BuildContext context) {
    final pastWeek = history.take(7).toList();
    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Tasks Records',
            subtitle: 'Last 7 schedules at a glance',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 14),
          if (pastWeek.isEmpty)
            Text(
              'You haven\'t logged a full day yet. Tomorrow counts toward '
              'your streak.',
              style: AppTextStyles.bodyMedium,
            )
          else
            Column(
              children: [
                for (final date in pastWeek)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppColors.limeAccent),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE · MMM d').format(date),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
