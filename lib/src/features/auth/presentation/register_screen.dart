import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/networking/api_exception.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String _role = 'client';
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
      _loading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmController.text,
            phone: _phoneController.text.trim(),
            role: _role,
            city: _cityController.text.trim(),
          );
      if (mounted) context.goNamed(AppRouteNames.dashboard);
    } on ApiException catch (e) {
      setState(() {
        _fieldErrors = e.validationErrors ?? const {};
        _error = localizeApiException(context, e);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
    final canPop = context.canPop();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: backTooltip,
              )
            : null,
        title: Text(l10n.register),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AppResponsiveCenter(
          maxWidth: 620,
          padding: EdgeInsets.zero,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthHeader(
                        eyebrow: 'Lem3alam',
                        title: l10n.createAccountTitle,
                        subtitle: l10n.createAccountSubtitle,
                      ),
                      const SizedBox(height: 20),
                      AppSectionCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AppRoleCard(
                                    title: l10n.needService,
                                    subtitle: l10n.needServiceSubtitle,
                                    icon: Icons.handyman_outlined,
                                    selected: _role == 'client',
                                    accentColor: Lem3alamColors.primaryBlue,
                                    onTap: () => setState(() => _role = 'client'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppRoleCard(
                                    title: l10n.wantWork,
                                    subtitle: l10n.wantWorkSubtitle,
                                    icon: Icons.work_history_outlined,
                                    selected: _role == 'tasker',
                                    accentColor: Lem3alamColors.accentGreen,
                                    onTap: () => setState(() => _role = 'tasker'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _dividerWithLabel(context, l10n.register),
                            const SizedBox(height: 18),
                            Form(
                              key: _formKey,
                              child: AutofillGroup(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_error != null) AppInlineBanner(message: _error!, tone: AppBannerTone.error),
                                    if (_error != null) const SizedBox(height: 14),
                                    _SectionTitle(title: l10n.personalInformation, subtitle: l10n.personalInformationSubtitle),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _nameController,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.name],
                                      decoration: InputDecoration(
                                        labelText: l10n.name,
                                        prefixIcon: const Icon(Icons.person_outline),
                                        errorText: _fieldErrors['name']?.first,
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                    ),
                                    const SizedBox(height: 14),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final narrow = constraints.maxWidth < 480;
                                        if (narrow) {
                                          return Column(
                                            children: [
                                              TextFormField(
                                                controller: _emailController,
                                                keyboardType: TextInputType.emailAddress,
                                                textInputAction: TextInputAction.next,
                                                autofillHints: const [AutofillHints.email],
                                                decoration: InputDecoration(
                                                  labelText: l10n.email,
                                                  prefixIcon: const Icon(Icons.email_outlined),
                                                  errorText: _fieldErrors['email']?.first,
                                                ),
                                                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                              ),
                                              const SizedBox(height: 14),
                                              TextFormField(
                                                controller: _phoneController,
                                                keyboardType: TextInputType.phone,
                                                textInputAction: TextInputAction.next,
                                                autofillHints: const [AutofillHints.telephoneNumber],
                                                decoration: InputDecoration(
                                                  labelText: l10n.phone,
                                                  prefixIcon: const Icon(Icons.phone_outlined),
                                                  errorText: _fieldErrors['phone']?.first,
                                                ),
                                                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                              ),
                                            ],
                                          );
                                        }
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _emailController,
                                                keyboardType: TextInputType.emailAddress,
                                                textInputAction: TextInputAction.next,
                                                autofillHints: const [AutofillHints.email],
                                                decoration: InputDecoration(
                                                  labelText: l10n.email,
                                                  prefixIcon: const Icon(Icons.email_outlined),
                                                  errorText: _fieldErrors['email']?.first,
                                                ),
                                                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _phoneController,
                                                keyboardType: TextInputType.phone,
                                                textInputAction: TextInputAction.next,
                                                autofillHints: const [AutofillHints.telephoneNumber],
                                                decoration: InputDecoration(
                                                  labelText: l10n.phone,
                                                  prefixIcon: const Icon(Icons.phone_outlined),
                                                  errorText: _fieldErrors['phone']?.first,
                                                ),
                                                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    AppCityPickerField(
                                      controller: _cityController,
                                      labelText: l10n.city,
                                      textInputAction: TextInputAction.next,
                                      errorText: _fieldErrors['city']?.first,
                                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                    ),
                                    const SizedBox(height: 14),
                                    DropdownButtonFormField<String>(
                                      value: _role,
                                      items: [
                                        DropdownMenuItem(value: 'client', child: Text(l10n.client)),
                                        DropdownMenuItem(value: 'tasker', child: Text(l10n.tasker)),
                                      ],
                                      onChanged: _loading ? null : (v) => setState(() => _role = v ?? 'client'),
                                      decoration: InputDecoration(
                                        labelText: l10n.role,
                                        prefixIcon: const Icon(Icons.badge_outlined),
                                        errorText: _fieldErrors['role']?.first,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _SectionTitle(title: l10n.security, subtitle: l10n.securitySubtitle),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.newPassword],
                                      decoration: InputDecoration(
                                        labelText: l10n.password,
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        helperText: l10n.passwordHint,
                                        helperMaxLines: 2,
                                        errorText: _fieldErrors['password']?.first,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.length < 8) ? l10n.passwordTooShort : null,
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _passwordConfirmController,
                                      obscureText: _obscurePasswordConfirm,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.newPassword],
                                      onFieldSubmitted: (_) {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          _submit();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: l10n.passwordConfirm,
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        errorText: _fieldErrors['password_confirmation']?.first,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                                          icon: Icon(
                                            _obscurePasswordConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => (v != _passwordController.text) ? l10n.passwordMismatch : null,
                                    ),
                                    const SizedBox(height: 10),
                                    _PasswordStrength(password: _passwordController),
                                    const SizedBox(height: 22),
                                    FilledButton(
                                      onPressed: _loading
                                          ? null
                                          : () {
                                              if (_formKey.currentState?.validate() ?? false) {
                                                _submit();
                                              }
                                            },
                                      child: _loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(l10n.register),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.arrow_forward_rounded, size: 18),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.alreadyHaveAccount,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: 6),
                                        TextButton(
                                          onPressed: _loading ? null : () => context.goNamed(AppRouteNames.login),
                                          child: Text(l10n.login),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dividerWithLabel(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.6), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.6), height: 1)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _PasswordStrength extends StatefulWidget {
  const _PasswordStrength({required this.password});

  final TextEditingController password;

  @override
  State<_PasswordStrength> createState() => _PasswordStrengthState();
}

class _PasswordStrengthState extends State<_PasswordStrength> {
  @override
  void initState() {
    super.initState();
    widget.password.addListener(_listener);
  }

  @override
  void dispose() {
    widget.password.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  int _score(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = _score(widget.password.text);
    final pct = (score / 5).clamp(0.0, 1.0);
    final Color color;
    final String label;
    if (score <= 1) {
      color = colorScheme.error;
      label = 'Weak';
    } else if (score <= 2) {
      color = Colors.orange;
      label = 'Fair';
    } else if (score <= 3) {
      color = const Color(0xFFF59E0B);
      label = 'Good';
    } else {
      color = Lem3alamColors.accentGreen;
      label = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Password strength: $label',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.title,
    required this.subtitle,
    this.eyebrow,
  });

  final String? eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Lem3alamColors.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.person_add_alt_1_rounded, color: Lem3alamColors.primaryBlue, size: 30),
        ),
        const SizedBox(height: 16),
        if ((eyebrow ?? '').isNotEmpty) ...[
          Text(
            eyebrow!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Lem3alamColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
