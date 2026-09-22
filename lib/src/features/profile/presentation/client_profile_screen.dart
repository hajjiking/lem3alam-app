import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import '../application/client_profile_controller.dart';
import '../domain/client_profile.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(clientProfileControllerProvider);

    Future<void> refresh() async {
      try {
        await ref.read(clientProfileControllerProvider.notifier).refresh();
      } catch (_) {}
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHeader(
              appName: context.l10n.appName,
              greeting: context.l10n.clientProfileTitle,
              subtitle: context.l10n.clientProfileSubtitle,
              availabilityLabel: '',
              isOnline: false,
              showAvailability: false,
              compact: true,
              avatarAsset: null,
              menuLabel: context.l10n.dashboardMenu,
              notificationsLabel: context.l10n.dashboardNotifications,
              profileLabel: context.l10n.dashboardProfile,
              onMenuTap: () => showDashboardMenu(context, ref),
              onNotificationsTap: () => openNotifications(context),
              onProfileTap: () {},
              onAvailabilityTap: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: profile.when(
                    skipLoadingOnRefresh: false,
                    skipLoadingOnReload: false,
                    loading: () => const Padding(
                      padding: EdgeInsets.all(64),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => _LoadError(
                      error: error,
                      onRetry: refresh,
                    ),
                    data: (data) => _ProfileContent(
                      profile: data,
                      onEdit: () => _editProfile(context, ref, data),
                      onLogout: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) {
                          context.goNamed(AppRouteNames.login);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    ClientProfile profile,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _EditProfileSheet(profile: profile),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.clientProfileSaved)),
        );
    }
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({
    required this.profile,
    required this.onEdit,
    required this.onLogout,
  });

  final ClientProfile profile;
  final VoidCallback onEdit;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final initials = profile.name.trim().isEmpty
        ? '?'
        : profile.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.characters.first.toUpperCase())
            .join();
    final location = profile.location.trim().isNotEmpty
        ? profile.location.trim()
        : profile.city.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(profile.email, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Chip(
                  avatar: Icon(
                    profile.isVerified
                        ? Icons.verified_user_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    profile.isVerified
                        ? l.clientProfileVerified
                        : l.clientProfileNotVerified,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.profileEdit),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: l.clientProfileContact,
          children: [
            _InfoTile(
              icon: Icons.phone_outlined,
              label: l.phone,
              value: _fallback(profile.phone, l.profileNotRecorded),
            ),
            _InfoTile(
              icon: Icons.location_on_outlined,
              label: l.location,
              value: _fallback(location, l.profileNotRecorded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l.settings,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l.notificationsTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.pushNamed(AppRouteNames.notifications),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l.languageAction),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showLanguagePicker(context),
            ),
            ListTile(
              leading: const Icon(Icons.contrast_rounded),
              title: Text(l.clientProfileAppearance),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  ref.read(themeModeControllerProvider.notifier).toggle(),
            ),
            ListTile(
              leading:
                  Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              title: Text(l.logout,
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: onLogout,
            ),
          ],
        ),
      ],
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final ClientProfile profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  bool _saving = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(text: widget.profile.email);
    _phone = TextEditingController(text: widget.profile.phone);
    _location = TextEditingController(
      text: widget.profile.location.isNotEmpty
          ? widget.profile.location
          : widget.profile.city,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
    });
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(clientProfileControllerProvider.notifier).save(
            ClientProfileUpdate(
              name: _name.text,
              email: _email.text,
              phone: _phone.text,
              location: _location.text,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _fieldErrors = error.validationErrors ?? const {};
          _error = localizeApiException(context, error);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.errUnknown);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.clientProfileEditTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            _field(
              controller: _name,
              label: l.name,
              icon: Icons.person_outline_rounded,
              serverKey: 'name',
              required: true,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _email,
              label: l.email,
              icon: Icons.email_outlined,
              serverKey: 'email',
              keyboardType: TextInputType.emailAddress,
              required: true,
              email: true,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _phone,
              label: l.phone,
              icon: Icons.phone_outlined,
              serverKey: 'phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _location,
              label: l.location,
              icon: Icons.location_on_outlined,
              serverKey: 'location',
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String serverKey,
    bool required = false,
    bool email = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        errorText: _fieldErrors[serverKey]?.firstOrNull,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return context.l10n.clientProfileRequired;
        if (email && text.isNotEmpty && !text.contains('@')) {
          return context.l10n.clientProfileInvalidEmail;
        }
        return null;
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              context.l10n.clientProfileLoadError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      );
}

String _fallback(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value.trim();
