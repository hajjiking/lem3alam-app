import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_theme.dart';
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
    } on ApiException catch (error) {
      setState(() {
        _fieldErrors = error.validationErrors ?? const {};
        _error = localizeApiException(context, error);
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = MediaQuery.sizeOf(context).width < 390;
    return Scaffold(
      backgroundColor: context.appColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                const SliverToBoxAdapter(child: _Hero()),
                SliverToBoxAdapter(
                  child: _LoginPanel(
                    compact: compact,
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    loading: _loading,
                    obscurePassword: _obscurePassword,
                    error: _error,
                    fieldErrors: _fieldErrors,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1774 / 867,
      child: Image.asset(
        'assets/login_header.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        semanticLabel: 'Welcome back to Lem3alam',
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.compact,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.obscurePassword,
    required this.error,
    required this.fieldErrors,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.l10n,
  });

  final bool compact;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final bool obscurePassword;
  final String? error;
  final Map<String, List<String>> fieldErrors;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final blue = context.appColors.primary;
    return Container(
      padding: EdgeInsets.all(compact ? AppStyle.pagePadding : 24),
      decoration: BoxDecoration(
          color: context.appColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyle.sheetRadius))),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.appColors.onSurface)),
              const SizedBox(height: 4),
              Text(l10n.loginSubtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: context.appColors.onSurfaceVariant)),
              const SizedBox(height: 26),
              if (error != null) ...[
                _ErrorMessage(message: error!),
                const SizedBox(height: 14)
              ],
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email
                ],
                decoration: InputDecoration(
                    hintText: l10n.email,
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: blue),
                    errorText: fieldErrors['email']?.first),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) {
                  if (formKey.currentState?.validate() ?? false) {
                    onSubmit();
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.password,
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: blue),
                  errorText: fieldErrors['password']?.first,
                  suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.requiredField : null,
              ),
              Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                      onPressed: loading ? null : () {},
                      child: const Text('Forgot password?'))),
              const SizedBox(height: 8),
              SizedBox(
                height: AppStyle.controlHeight,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            onSubmit();
                          }
                        },
                  child: loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.appColors.onPrimary))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(l10n.login),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded)
                        ]),
                ),
              ),
              const SizedBox(height: 26),
              const _OrDivider(),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(
                      child:
                          _SocialButton(label: 'Google', icon: _GoogleMark())),
                  SizedBox(width: 12),
                  Expanded(
                      child: _SocialButton(
                          label: 'Facebook',
                          icon: Icon(Icons.facebook_rounded,
                              color: Color(0xFF1877F2), size: 28))),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.noAccountYet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appColors.onSurfaceVariant)),
                  TextButton(
                      onPressed: loading
                          ? null
                          : () => context.goNamed(AppRouteNames.register),
                      child: Text(l10n.register)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: context.appColors.errorContainer,
            borderRadius: BorderRadius.circular(14)),
        child: Text(message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.appColors.onErrorContainer)),
      );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider()),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('or continue with',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.appColors.onSurfaceVariant))),
        const Expanded(child: Divider()),
      ]);
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});
  final String label;
  final Widget icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: AppStyle.controlHeight,
        child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.appColors.onSurface)))
            ])),
      );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) => const Text('G',
      style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF4285F4)));
}
