import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/body_measurement.dart';
import '../../models/user_profile.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';
import '../body_progress/body_progress_screen.dart';
import '../check_in/check_in_screen.dart';
import '../journal/journal_screen.dart';
import '../profile/profile_screen.dart';
import '../schedule/schedule_screen.dart';
import '../welcome/welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _DashboardHome(),
      const SchedulePage(),
      const CheckInScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      drawer: const _FifeDrawer(),
      body: AmbientBackground(
        child: SafeArea(
          child: pages[_bottomIndex],
        ),
      ),
      bottomNavigationBar: _FifeBottomBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  late Future<List<BodyMeasurement>> _measurementsFuture;

  @override
  void initState() {
    super.initState();
    _measurementsFuture = _load();
  }

  Future<List<BodyMeasurement>> _load() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return const [];
    return LocalStorage.instance.measurements(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final user = session.user;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: _DashboardAppBar(user: user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: _GreetingCard(user: user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: _ProfileProgressCard(user: user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: FutureBuilder<List<BodyMeasurement>>(
              future: _measurementsFuture,
              builder: (context, snapshot) {
                final list = snapshot.data ?? const [];
                return _BodyProgressTeaser(measurements: list);
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: _ProgramsSection(user: user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: _QuickActions(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar({required this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        const Spacer(),
        const FifeLogo(size: 24),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 18),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.limeAccent, width: 1.4),
            color: AppColors.surfaceMuted,
          ),
          alignment: Alignment.center,
          child: Text(
            (user?.email.substring(0, 1).toUpperCase()) ?? 'F',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.limeAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final firstName = user?.fullName?.split(' ').first ??
        user?.email.split('@').first ??
        'FIFER';
    return FifeCard(
      glow: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.limeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.limeAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 14, color: AppColors.limeAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Coach Fife',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.limeAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Today',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hey $firstName 👋',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Small progress adds up. Let\'s make today another step in '
            'your transformation.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard({required this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final completion = user?.profileCompletion ?? 0;
    final percent = (completion / 10).clamp(0, 1);

    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Profile Progress',
            subtitle: 'Set up your profile to unlock projections',
            icon: Icons.donut_large_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$completion / 10',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.limeAccent,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 130,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: percent.toDouble(),
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.limeAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GhostButton(
            label: completion >= 10 ? 'Edit My Profile' : 'Complete Profile',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyProgressTeaser extends StatelessWidget {
  const _BodyProgressTeaser({required this.measurements});
  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final hasData = measurements.isNotEmpty;
    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Body Progress',
            subtitle: 'Bust · Waist · Hips · Weight',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_graph_rounded,
                      color: AppColors.limeAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Empty body progress graph. Take your first '
                      'measurement to seed your transformation arc.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            _MiniMetrics(latest: measurements.last),
          const SizedBox(height: 16),
          GlowButton(
            label: hasData ? 'Update Body Map' : 'Fill Body Progress Map',
            icon: Icons.add_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BodyProgressScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetrics extends StatelessWidget {
  const _MiniMetrics({required this.latest});
  final BodyMeasurement latest;

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, String value) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.limeAccent,
                  ),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile('Bust', '${latest.bustInches.toStringAsFixed(1)}"'),
        tile('Waist', '${latest.waistBellyButtonInches.toStringAsFixed(1)}"'),
        tile('Hips', '${latest.hipsInches.toStringAsFixed(1)}"'),
        tile('Weight', '${latest.weightKg.toStringAsFixed(1)}kg'),
      ],
    );
  }
}

class _ProgramsSection extends StatelessWidget {
  const _ProgramsSection({required this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final hasProgram = (user?.currentProgramName ?? '').isNotEmpty;

    return FifeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Programs',
            subtitle: 'Current and recommended for your goal',
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B1E23), Color(0xFF12141A)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.limeAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.limeAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: AppColors.limeAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasProgram
                            ? user!.currentProgramName!
                            : 'No active program',
                        style: AppTextStyles.headingSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasProgram
                            ? user!.currentProgramDuration ??
                                '4 weeks · Week 1'
                            : 'Pick a program to begin tracking',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('RECOMMENDED', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _RecommendedTile(
                  title: 'Body Define',
                  subtitle: '4-Week Sculpt',
                  icon: Icons.accessibility_new_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _RecommendedTile(
                  title: 'Lean Lift',
                  subtitle: '6-Week Reset',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  const _RecommendedTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.limeAccent),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  Widget _tile(BuildContext context,
      {required IconData icon,
      required String label,
      required Widget Function() builder}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => builder())),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.limeAccent),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tile(context,
            icon: Icons.straighten_rounded,
            label: 'Body Map',
            builder: () => const BodyProgressScreen()),
        _tile(context,
            icon: Icons.menu_book_rounded,
            label: 'Journal',
            builder: () => const JournalScreen()),
        _tile(context,
            icon: Icons.event_available_rounded,
            label: 'Schedule',
            builder: () => const SchedulePage()),
        _tile(context,
            icon: Icons.check_circle_outline_rounded,
            label: 'Check In',
            builder: () => const CheckInScreen()),
      ],
    );
  }
}

class _FifeBottomBar extends StatelessWidget {
  const _FifeBottomBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppColors.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_rounded),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_rounded),
              label: 'Check In',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _FifeDrawer extends StatelessWidget {
  const _FifeDrawer();

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final user = session.user;
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.limeAccent.withValues(alpha: 0.18),
                      border:
                          Border.all(color: AppColors.limeAccent, width: 1.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (user?.email.substring(0, 1).toUpperCase()) ?? 'F',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.limeAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'FIFER',
                          style: AppTextStyles.headingSmall,
                        ),
                        Text(
                          user?.email ?? 'guest@fife.app',
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerTile(
                    icon: Icons.straighten_rounded,
                    label: 'Body Progress Map',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const BodyProgressScreen()));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.menu_book_rounded,
                    label: 'My Fit Journal',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const JournalScreen()));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.event_available_rounded,
                    label: 'My Fit Schedule',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SchedulePage()));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Check In',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CheckInScreen()));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.person_outline_rounded,
                    label: 'My Fit Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ProfileScreen()));
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: Text(
                'Sign out',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.danger),
              ),
              onTap: () async {
                await SessionScope.of(context, listen: false).signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.limeAccent),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

