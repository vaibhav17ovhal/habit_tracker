import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/gamification_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/leaderboard_provider.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/rewards_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/screens/edit_profile_screen.dart';
import 'package:Demo/screens/privacy_policy_screen.dart';
import 'package:Demo/screens/terms_and_condition_screen.dart';
import 'package:Demo/services/api_service.dart';
import 'package:Demo/utils/auth_navigation.dart';
import 'package:Demo/widgets/animated_theme_toggle.dart';
import 'package:Demo/widgets/profile_gamification_card.dart';
import 'package:Demo/widgets/profile_leaderboard_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final habitsProvider = context.watch<HabitsProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final rewardsProvider = context.read<RewardsProvider>();
    final gamificationProvider = context.read<GamificationProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();
    final gamificationStats = gamificationProvider.statsFor(
      habits: habitsProvider,
      progress: progressProvider,
      rewards: rewardsProvider,
    );
    final leaderboardEntries = leaderboardProvider.buildLeaderboard(
      user: userProvider,
      habits: habitsProvider,
      progress: progressProvider,
      rewards: rewardsProvider,
      gamification: gamificationProvider,
    );
    final currentUserEntry =
        leaderboardProvider.currentUserEntry(leaderboardEntries);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(
              name: userProvider.displayName,
              email: userProvider.displayEmail,
              avatarPath: userProvider.avatarPath,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ProfileGamificationCard(stats: gamificationStats),
            const SizedBox(height: 16),
            ProfileLeaderboardSection(
              entries: leaderboardEntries,
              currentUser: currentUserEntry,
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Profile',
              children: [
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update name and email',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Theme',
                  trailing: AnimatedThemeToggle(
                    isDark: userProvider.isDarkTheme,
                    onChanged: (_) => userProvider.toggleTheme(),
                  ),
                  showChevron: false,
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Daily habit reminders',
                  trailing: Switch.adaptive(
                    value: userProvider.notificationsEnabled,
                    activeThumbColor: MyColors.primaryBlue,
                    onChanged: userProvider.toggleNotifications,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsAndConditionScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  showChevron: false,
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  titleColor: const Color(0xFFEF4444),
                  iconColor: const Color(0xFFEF4444),
                  onTap: () => _logout(context),
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your data',
                  titleColor: const Color(0xFFEF4444),
                  iconColor: const Color(0xFFEF4444),
                  onTap: () => _deleteAccount(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<DashboardProvider>().reset();

    try {
      await context.read<UserProvider>().logout();
    } catch (e) {
      if (context.mounted) showApiErrorSnackBar(context, e);
      return;
    }

    navigateToSignIn(clearLoginFlag: false);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: GoogleFonts.poppins()),
        content: Text(
          'This will permanently delete your profile, habits, progress, '
          'and mood data. This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<DashboardProvider>().reset();

    try {
      await context.read<UserProvider>().deleteAccount();
      await context.read<HabitsProvider>().clearAll();
      await context.read<ProgressProvider>().loadFromStorage();
      await context.read<MoodProvider>().loadFromStorage();
    } catch (e) {
      if (context.mounted) showApiErrorSnackBar(context, e);
      return;
    }

    navigateToSignIn(clearLoginFlag: false);
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String avatarPath;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : MyColors.neutralGray,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundImage: AssetImage(avatarPath),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MyColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : MyColors.neutralGray,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? MyColors.primaryBlue, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: titleColor ??
                            (isDark ? Colors.white : MyColors.kBlackColor),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: MyColors.kDescriptionColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showChevron && onTap != null)
                Icon(Icons.chevron_right, color: MyColors.kDescriptionColor),
            ],
          ),
        ),
      ),
    );
  }
}
