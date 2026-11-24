import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showEditProfileDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user found')),
      );
      return;
    }

    final nameController = TextEditingController(text: user.displayName ?? '');

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0B2238),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Edit profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dialogDecoration(
                      label: 'Display name',
                      hint: 'Enter your name',
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result != true) return;

      await user.updateDisplayName(nameController.text.trim());
      await user.reload();

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to update profile')),
      );
    } finally {
      nameController.dispose();
    }
  }
  InputDecoration _dialogDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _ProfileBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: service.watchSettings(),
              builder: (context, snapshot) {
                final settings = snapshot.data ?? UserSettings();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _ProfileHero(user: user),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Notifications',
                      subtitle: 'Control background alerts on this phone',
                    ),
                    const SizedBox(height: 12),
                    _GlassShell(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.09),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Background notifications',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Turn on to show alerts on the phone background. Turn off to silence them.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.72),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.notificationsEnabled,
                              activeColor: const Color(0xFF38BDF8),
                              onChanged: (value) async {
                                await service.updateSettings(
                                  UserSettings(
                                    householdSize: settings.householdSize,
                                    monthlyTarget: settings.monthlyTarget,
                                    sleepStart: settings.sleepStart,
                                    sleepEnd: settings.sleepEnd,
                                    notificationsEnabled: value,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Account',
                      subtitle: 'Personal details and access',
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit profile',
                      subtitle: 'Name, email, and photo',
                      onTap: _showEditProfileDialog,
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Settings',
                      subtitle: 'Household, target, and sleep schedule',
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.settings_outlined,
                      title: 'App settings',
                      subtitle: 'Open household, target, and sleep controls',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      title: 'Preferences',
                      subtitle: 'Customize your experience',
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle:
                          'Current: ${ThemeService.instance.selectedOption.name}',
                      onTap: () => _showThemePicker(context),
                    ),
                    const SizedBox(height: 16),
                    _GlassButton(
                      icon: Icons.logout_rounded,
                      label: 'Sign out',
                      accent: const Color(0xFFF97316),
                      onTap: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showThemePicker(BuildContext context) async {
  final themeService = ThemeService.instance;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _GlassShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose theme',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a color palette that fits your style.',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
              ),
              const SizedBox(height: 16),
              ...themeService.options.map((option) {
                final isSelected = option.preset == themeService.selectedPreset;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        themeService.selectTheme(option.preset);
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${option.name} applied'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isSelected
                              ? option.accentColor.withOpacity(0.18)
                              : Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: isSelected
                                ? option.accentColor.withOpacity(0.55)
                                : Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    option.seedColor,
                                    option.accentColor,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.subtitle,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.72),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _GlowBlob(
                size: 240,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: _GlowBlob(
                size: 210,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -40,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();
    final fallbackLabel = user?.email ?? 'Water Monitor User';
    final photoUrl = user?.photoURL;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7DD3FC),
                    Color(0xFF38BDF8),
                    Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasPhoto
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName?.isNotEmpty == true ? displayName! : fallbackLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if ((user?.email ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                user!.email!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.74),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: accent.withOpacity(0.16),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}




