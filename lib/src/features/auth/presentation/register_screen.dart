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
      setState(() => _error = 'Please accept the Terms & Conditions to continue.');
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
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _RegisterHero(compact: compact)),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
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
                      onTermsChanged: (accepted) => setState(() => _acceptedTerms = accepted),
                      onPasswordVisibilityChanged: () => setState(() => _obscurePassword = !_obscurePassword),
                      onSubmit: _submit,
                    ),
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
  const _RegisterHero({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 268 : 300,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEAF2FF), Color(0xFFD7E7FF), Color(0xFFF0F6FF)]),
        ),
        child: Stack(
          children: [
            Positioned(right: -60, bottom: -90, child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .27)))),
            Positioned(
              left: 26,
              top: compact ? 52 : 64,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Image.asset('assets/logo.png', width: compact ? 180 : 218),
                const SizedBox(height: 10),
                Text('Skilled Professionals,\nRight at Your Service', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF435887), fontWeight: FontWeight.w600, height: 1.45)),
              ]),
            ),
            Positioned(
              right: -16,
              bottom: -32,
              child: SizedBox(
                height: compact ? 225 : 248,
                width: compact ? 170 : 190,
                child: Image.asset('assets/artisan_cutout.png', fit: BoxFit.cover, alignment: Alignment.topCenter, color: Colors.white, colorBlendMode: BlendMode.screen),
              ),
            ),
          ],
        ),
      );
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.compact, required this.formKey, required this.l10n, required this.nameController, required this.emailController,
    required this.phoneController, required this.cityController, required this.passwordController, required this.role,
    required this.acceptedTerms, required this.loading, required this.obscurePassword, required this.error, required this.errors,
    required this.onRoleChanged, required this.onTermsChanged, required this.onPasswordVisibilityChanged, required this.onSubmit,
  });

  final bool compact;
  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final TextEditingController nameController, emailController, phoneController, cityController, passwordController;
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
    const blue = Lem3alamColors.primaryBlue;
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 22 : 34, 32, compact ? 22 : 34, 34),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(38))),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Create Your Account 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF111B48))),
            const SizedBox(height: 4),
            Text('Join lem3alam and find the right professional for your needs, or offer your services to more people.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF66789F), height: 1.35)),
            const SizedBox(height: 22),
            if (error != null) ...[_ErrorMessage(message: error!), const SizedBox(height: 14)],
            _Field(controller: nameController, hint: 'Full Name', icon: Icons.person_outline_rounded, error: errors['name']?.first, action: TextInputAction.next, autofill: const [AutofillHints.name], validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(controller: emailController, hint: 'Email address', icon: Icons.mail_outline_rounded, error: errors['email']?.first, action: TextInputAction.next, keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.email], validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(controller: phoneController, hint: 'Phone number', icon: Icons.phone_outlined, error: errors['phone']?.first, action: TextInputAction.next, keyboard: TextInputType.phone, autofill: const [AutofillHints.telephoneNumber], validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            _Field(controller: cityController, hint: l10n.city, icon: Icons.location_city_outlined, error: errors['city']?.first, action: TextInputAction.next, validator: (value) => _required(value, l10n)),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController, obscureText: obscurePassword, textInputAction: TextInputAction.done, autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) { if (formKey.currentState?.validate() ?? false) onSubmit(); },
              decoration: InputDecoration(hintText: l10n.password, prefixIcon: const Icon(Icons.lock_outline_rounded, color: blue), errorText: errors['password']?.first, suffixIcon: IconButton(onPressed: onPasswordVisibilityChanged, icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
              validator: (value) => value == null || value.length < 8 ? l10n.passwordTooShort : null,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F6FF), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('I want to register as:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF111B48))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _RoleButton(label: 'Professional', icon: Icons.person_outline_rounded, selected: role == 'tasker', onTap: () => onRoleChanged('tasker'))),
                  const SizedBox(width: 10),
                  Expanded(child: _RoleButton(label: 'Client', icon: Icons.person_outline_rounded, selected: role == 'client', onTap: () => onRoleChanged('client'))),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF66789F),
                              ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(color: Lem3alamColors.primaryBlue, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Lem3alamColors.primaryBlue, fontWeight: FontWeight.w800),
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
            SizedBox(height: 58, child: FilledButton(
              onPressed: loading ? null : () { if (formKey.currentState?.validate() ?? false) onSubmit(); },
              style: FilledButton.styleFrom(backgroundColor: blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
              child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Row(mainAxisSize: MainAxisSize.min, children: [Text(l10n.register), const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded)]),
            )),
            const SizedBox(height: 22),
            const _OrDivider(),
            const SizedBox(height: 18),
            SizedBox(height: 58, child: OutlinedButton(onPressed: () {}, child: const Row(mainAxisSize: MainAxisSize.min, children: [_GoogleMark(), SizedBox(width: 14), Text('Sign up with Google', style: TextStyle(color: Color(0xFF111B48)))]))),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(l10n.alreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66789F))), TextButton(onPressed: loading ? null : () => context.goNamed(AppRouteNames.login), child: Text(l10n.login))]),
          ]),
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) => value == null || value.trim().isEmpty ? l10n.requiredField : null;
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, required this.icon, required this.error, required this.action, this.keyboard, this.autofill, required this.validator});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? error;
  final TextInputAction action;
  final TextInputType? keyboard;
  final Iterable<String>? autofill;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) => TextFormField(controller: controller, keyboardType: keyboard, textInputAction: action, autofillHints: autofill, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Lem3alamColors.primaryBlue), errorText: error), validator: validator);
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(height: 54, child: FilledButton.tonal(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: selected ? Lem3alamColors.primaryBlue : Colors.white, foregroundColor: selected ? Colors.white : const Color(0xFF111B48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 22), const SizedBox(width: 8), Flexible(child: Text(label, overflow: TextOverflow.ellipsis))])));
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFECEB), borderRadius: BorderRadius.circular(14)), child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFB42318))));
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66789F)))), const Expanded(child: Divider())]);
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) => const Text('G', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)));
}
