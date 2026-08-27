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
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String _role = 'tasker';
  bool _acceptedTerms = false;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      setState(
          () => _error = 'Please accept the Terms & Conditions to continue.');
      return;
    }
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
            passwordConfirmation: _passwordController.text,
            phone: _phoneController.text.trim(),
            role: _role,
            city: _cityController.text.trim(),
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                const SliverToBoxAdapter(child: _RegisterHero()),
                SliverToBoxAdapter(
                  child: _RegisterPanel(
                    compact: compact,
                    formKey: _formKey,
                    l10n: l10n,
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    cityController: _cityController,
                    passwordController: _passwordController,
                    role: _role,
                    acceptedTerms: _acceptedTerms,
                    loading: _loading,
                    obscurePassword: _obscurePassword,
                    error: _error,
                    errors: _fieldErrors,
                    onRoleChanged: (role) => setState(() => _role = role),
                    onTermsChanged: (accepted) =>
                        setState(() => _acceptedTerms = accepted),
                    onPasswordVisibilityChanged: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
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

class _RegisterHero extends StatelessWidget {
  const _RegisterHero();

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1733 / 675,
        child: Image.asset(
          'assets/register_header.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          semanticLabel: 'Create your Lem3alam account',
        ),
      );
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.compact,
    required this.formKey,
    required this.l10n,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
    required this.passwordController,
    required this.role,
    required this.acceptedTerms,
    required this.loading,
    required this.obscurePassword,
    required this.error,
    required this.errors,
    required this.onRoleChanged,
    required this.onTermsChanged,
    required this.onPasswordVisibilityChanged,
    required this.onSubmit,
  });

  final bool compact;
  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final TextEditingController nameController,
      emailController,
      phoneController,
      cityController,
      passwordController;
  final String role;
  final bool acceptedTerms, loading, obscurePassword;
  final String? error;
  final Map<String, List<String>> errors;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onPasswordVisibilityChanged;
  final Future<void> Function() onSubmit;

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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.createAccountTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.appColors.onSurface)),
            const SizedBox(height: 4),
            Text(l10n.createAccountSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appColors.onSurfaceVariant, height: 1.35)),
            const SizedBox(height: 22),
            if (error != null) ...[
              _ErrorMessage(message: error!),
              const SizedBox(height: 14)
            ],
            _Field(
                controller: nameController,
                hint: l10n.name,
                icon: Icons.person_outline_rounded,
                error: errors['name']?.first,
                action: TextInputAction.next,
                autofill: const [AutofillHints.name],
                validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(
                controller: emailController,
                hint: l10n.email,
                icon: Icons.mail_outline_rounded,
                error: errors['email']?.first,
                action: TextInputAction.next,
                keyboard: TextInputType.emailAddress,
                autofill: const [AutofillHints.email],
                validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(
                controller: phoneController,
                hint: l10n.phone,
                icon: Icons.phone_outlined,
                error: errors['phone']?.first,
                action: TextInputAction.next,
                keyboard: TextInputType.phone,
                autofill: const [AutofillHints.telephoneNumber],
                validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(
                controller: cityController,
                hint: l10n.city,
                icon: Icons.location_city_outlined,
                error: errors['city']?.first,
                action: TextInputAction.next,
                validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  onSubmit();
                }
              },
              decoration: InputDecoration(
                  hintText: l10n.password,
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: blue),
                  errorText: errors['password']?.first,
                  suffixIcon: IconButton(
                      onPressed: onPasswordVisibilityChanged,
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined))),
              validator: (value) => value == null || value.length < 8
                  ? l10n.passwordTooShort
                  : null,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: context.appColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.role,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.appColors.onSurface)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _RoleButton(
                              label: l10n.tasker,
                              icon: Icons.person_outline_rounded,
                              selected: role == 'tasker',
                              onTap: () => onRoleChanged('tasker'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _RoleButton(
                              label: l10n.client,
                              icon: Icons.person_outline_rounded,
                              selected: role == 'client',
                              onTap: () => onRoleChanged('client'))),
                    ]),
                  ]),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => onTermsChanged(!acceptedTerms),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (value) => onTermsChanged(value ?? false),
                    activeColor: blue,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: RichText(
                        text: TextSpan(
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.appColors.onSurfaceVariant,
                                  ),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                  color: context.appColors.primary,
                                  fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                  color: context.appColors.primary,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
                          Text(l10n.register),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded)
                        ]),
                )),
            const SizedBox(height: 22),
            const _OrDivider(),
            const SizedBox(height: 18),
            SizedBox(
                height: AppStyle.controlHeight,
                child: OutlinedButton(
                    onPressed: () {},
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _GoogleMark(),
                      SizedBox(width: 14),
                      Flexible(
                          child: Text('Sign up with Google',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: context.appColors.onSurface)))
                    ]))),
            const SizedBox(height: 18),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appColors.onSurfaceVariant)),
                  TextButton(
                      onPressed: loading
                          ? null
                          : () => context.goNamed(AppRouteNames.login),
                      child: Text(l10n.login))
                ]),
          ]),
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) =>
      value == null || value.trim().isEmpty ? l10n.requiredField : null;
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.controller,
      required this.hint,
      required this.icon,
      required this.error,
      required this.action,
      this.keyboard,
      this.autofill,
      required this.validator});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? error;
  final TextInputAction action;
  final TextInputType? keyboard;
  final Iterable<String>? autofill;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textInputAction: action,
      autofillHints: autofill,
      decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: context.appColors.primary),
          errorText: error),
      validator: validator);
}

class _RoleButton extends StatelessWidget {
  const _RoleButton(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 54,
      child: FilledButton.tonal(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            backgroundColor: selected
                ? context.appColors.primary
                : context.appColors.surfaceContainerLowest,
            foregroundColor: selected
                ? context.appColors.onPrimary
                : context.appColors.onSurface,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis))
          ])));
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
              ?.copyWith(color: context.appColors.onErrorContainer)));
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider()),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('or',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.appColors.onSurfaceVariant))),
        const Expanded(child: Divider())
      ]);
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) => const Text('G',
      style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF4285F4)));
}
