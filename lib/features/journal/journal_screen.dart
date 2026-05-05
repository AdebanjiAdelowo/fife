import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/journal_entry.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/fife_card.dart';
import '../../widgets/fife_logo.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/session_scope.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late Future<List<JournalEntry>> _future;
  final _bodyCtrl = TextEditingController();
  JournalMood _mood = JournalMood.hopeful;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<JournalEntry>> _load() async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return const [];
    return LocalStorage.instance.journal(user.id);
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveEntry({required bool isFirst}) async {
    final user = SessionScope.of(context, listen: false).user;
    if (user == null) return;
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tell Coach Fife how you feel.')),
      );
      return;
    }
    final entry = JournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: isFirst
          ? 'Tell us all about your hopes and goals'
          : 'I\'m here. How are you feeling?',
      body: body,
      mood: _mood,
      createdAt: DateTime.now(),
      isFirstEntry: isFirst,
    );
    await LocalStorage.instance.saveJournalEntry(user.id, entry);
    _bodyCtrl.clear();
    setState(() {
      _future = _load();
      _mood = JournalMood.hopeful;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        showSideGlow: false,
        child: SafeArea(
          child: FutureBuilder<List<JournalEntry>>(
            future: _future,
            builder: (context, snapshot) {
              final entries = snapshot.data ?? const [];
              final firstEntry = entries.firstWhere(
                (e) => e.isFirstEntry,
                orElse: () => JournalEntry(
                  id: '',
                  title: '',
                  body: '',
                  mood: JournalMood.hopeful,
                  createdAt: DateTime.now(),
                ),
              );
              final hasFirstEntry = firstEntry.id.isNotEmpty;
              final history = entries.where((e) => !e.isFirstEntry).toList();

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
                      child: Text('My Fit Journal',
                          style: AppTextStyles.displayLarge),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: Text(
                        'A calm, honest space. Once written, entries are '
                        'preserved as part of your journey.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                  if (!hasFirstEntry)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _NewEntryCard(
                          headline:
                              'Tell us all about your hopes and goals as you '
                              'begin your fitness journey.',
                          ctrl: _bodyCtrl,
                          mood: _mood,
                          onMoodChanged: (m) => setState(() => _mood = m),
                          ctaLabel: 'Anchor My First Entry',
                          onSubmit: () => _saveEntry(isFirst: true),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _PinnedFirstEntryCard(entry: firstEntry),
                      ),
                    ),
                  if (hasFirstEntry)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: _NewEntryCard(
                          headline:
                              "I'm here. How are you feeling? Tell me everything…",
                          ctrl: _bodyCtrl,
                          mood: _mood,
                          onMoodChanged: (m) => setState(() => _mood = m),
                          ctaLabel: 'Save Entry',
                          onSubmit: () => _saveEntry(isFirst: false),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Text('HISTORY', style: AppTextStyles.label),
                    ),
                  ),
                  if (history.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          'Past entries will appear here. Read-only, '
                          'safekept.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (_, i) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: _EntryTile(entry: history[i]),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: history.length,
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

class _NewEntryCard extends StatelessWidget {
  const _NewEntryCard({
    required this.headline,
    required this.ctrl,
    required this.mood,
    required this.onMoodChanged,
    required this.ctaLabel,
    required this.onSubmit,
  });

  final String headline;
  final TextEditingController ctrl;
  final JournalMood mood;
  final ValueChanged<JournalMood> onMoodChanged;
  final String ctaLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF181B21), Color(0xFF111317)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: AppTextStyles.headingMedium),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 6,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Pour it out…',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JournalMood.values
                .map((m) => _MoodChip(
                      mood: m,
                      selected: m == mood,
                      onTap: () => onMoodChanged(m),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          GlowButton(
            label: ctaLabel,
            icon: Icons.edit_rounded,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final JournalMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.limeAccent.withValues(alpha: 0.18)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.limeAccent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji),
            const SizedBox(width: 6),
            Text(
              mood.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    selected ? AppColors.limeAccent : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedFirstEntryCard extends StatelessWidget {
  const _PinnedFirstEntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin_rounded,
                  color: AppColors.limeAccent),
              const SizedBox(width: 6),
              Text(
                'FIRST ENTRY · PINNED',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.limeAccent),
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd().format(entry.createdAt),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(entry.title, style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text(entry.body, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          Row(children: [
            Text(entry.mood.emoji,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(entry.mood.label, style: AppTextStyles.bodyMedium),
          ]),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return FifeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.mood.emoji),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM d · h:mm a').format(entry.createdAt),
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              Text(
                entry.mood.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.limeAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
