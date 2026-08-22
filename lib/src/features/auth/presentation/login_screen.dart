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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
      _loading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: canPop
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: backTooltip,
              )
            : null,
        title: Text(l10n.login),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ]
                : [
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: AppResponsiveCenter(
            maxWidth: 560,
            padding: EdgeInsets.zero,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AuthHeader(
                          eyebrow: 'Lem3alam',
                          title: l10n.welcomeBack,
                          subtitle: l10n.loginSubtitle,
                        ),
                        const SizedBox(height: 24),
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
                                      selected: true,
                                      accentColor: Lem3alamColors.primaryBlue,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppRoleCard(
                                      title: l10n.wantWork,
                                      subtitle: l10n.wantWorkSubtitle,
                                      icon: Icons.work_history_outlined,
                                      selected: false,
                                      accentColor: Lem3alamColors.accentGreen,
                                      onTap: () => context.goNamed(AppRouteNames.register),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _dividerWithLabel(context, l10n.login),
                              const SizedBox(height: 18),
                              Form(
                                key: _formKey,
                                child: AutofillGroup(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (_error != null) AppInlineBanner(message: _error!, tone: AppBannerTone.error),
                                      if (_error != null) const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                                        decoration: InputDecoration(
                                          labelText: l10n.email,
                                          prefixIcon: const Icon(Icons.email_outlined),
                                          errorText: _fieldErrors['email']?.first,
                                        ),
                                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [AutofillHints.password],
                                        onFieldSubmitted: (_) {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            _submit();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelText: l10n.password,
                                          prefixIcon: const Icon(Icons.lock_outline),
                                          errorText: _fieldErrors['password']?.first,
                                          suffixIcon: IconButton(
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            ),
                                          ),
                                        ),
                                        validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: AlignmentDirectional.centerEnd,
                                        child: TextButton(
                                          onPressed: _loading ? null : () {},
                                          style: TextButton.styleFrom(
                                            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                          child: const Text('Forgot password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FilledButton(
                                        onPressed: _loading
                                            ? null
                                            : () {
                                                if (_formKey.currentState?.validate() ?? false) {
                                                  _submit();
                                                }
                                              },
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size.fromHeight(52),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
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
                                                  Text(l10n.login),
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 14),
                                      _continueWith(context),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                        Text(
                                          l10n.noAccountYet,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: 6),
                                        TextButton(
                                          onPressed: _loading ? null : () => context.goNamed(AppRouteNames.register),
                                          child: Text(l10n.register),
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

  Widget _continueWith(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = Border.all(color: colorScheme.outlineVariant);
    return Row(
      children: [
        Expanded(
        child: _continueTile(icon: Icons.phone_android_outlined, label: 'Phone', onTap: () {}, border: border, colorScheme: colorScheme, context: context),
        ),
        const SizedBox(width: 12),
        Expanded(
        child: _continueTile(icon: Icons.g_mobiledata_rounded, label: 'Google', onTap: () {}, border: border, colorScheme: colorScheme, context: context),
        ),
      ],
    );
  }

  Widget _continueTile({
    required IconData icon,
    required String label,
    required BuildContext context,
    required ColorScheme colorScheme,
    required BoxBorder border,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: border,
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            color: isDark ? null : colorScheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Lem3alamColors.primaryBlue.withValues(alpha: 0.25),
                      Lem3alamColors.primaryBlue.withValues(alpha: 0.15),
                    ]
                  : [
                      Lem3alamColors.primaryBlue.withValues(alpha: 0.15),
                      Lem3alamColors.primaryBlue.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Lem3alamColors.primaryBlue.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Icon(Icons.handyman_rounded, color: Lem3alamColors.primaryBlue, size: 30),
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
