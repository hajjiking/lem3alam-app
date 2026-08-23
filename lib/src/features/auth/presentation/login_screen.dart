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
      backgroundColor: const Color(0xFFF7F9FF),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _Hero(compact: compact)),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: _LoginPanel(
                      compact: compact,
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      loading: _loading,
                      obscurePassword: _obscurePassword,
                      error: _error,
                      fieldErrors: _fieldErrors,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      onSubmit: _submit,
                      l10n: l10n,
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

class _Hero extends StatelessWidget {
  const _Hero({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 285 : 320,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FF), Color(0xFFD7E7FF), Color(0xFFF0F6FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -65,
            bottom: -95,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.27)),
            ),
          ),
          Positioned(
            left: 26,
            top: compact ? 66 : 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/logo.png', width: compact ? 180 : 218),
                const SizedBox(height: 10),
                Text(
                  'Skilled Professionals,\nRight at Your Service',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF435887), fontWeight: FontWeight.w600, height: 1.45),
                ),
              ],
            ),
          ),
          Positioned(
            right: -16,
            bottom: -28,
            child: SizedBox(
              height: compact ? 244 : 276,
              width: compact ? 185 : 210,
              child: Image.asset('assets/artisan_cutout.png', fit: BoxFit.cover, alignment: Alignment.topCenter, color: Colors.white, colorBlendMode: BlendMode.screen),
            ),
          ),
        ],
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
    const blue = Lem3alamColors.primaryBlue;
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 22 : 34, 32, compact ? 22 : 34, 34),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(38))),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome Back 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF111B48))),
              const SizedBox(height: 4),
              Text(l10n.loginSubtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF66789F))),
              const SizedBox(height: 26),
              if (error != null) ...[_ErrorMessage(message: error!), const SizedBox(height: 14)],
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                decoration: InputDecoration(hintText: 'Email address', prefixIcon: const Icon(Icons.mail_outline_rounded, color: blue), errorText: fieldErrors['email']?.first),
                validator: (value) => value == null || value.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) { if (formKey.currentState?.validate() ?? false) onSubmit(); },
                decoration: InputDecoration(
                  hintText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: blue),
                  errorText: fieldErrors['password']?.first,
                  suffixIcon: IconButton(onPressed: onTogglePassword, icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                ),
                validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
              ),
              Align(alignment: AlignmentDirectional.centerEnd, child: TextButton(onPressed: loading ? null : () {}, child: const Text('Forgot password?'))),
              const SizedBox(height: 8),
              SizedBox(
                height: 58,
                child: FilledButton(
                  onPressed: loading ? null : () { if (formKey.currentState?.validate() ?? false) onSubmit(); },
                  style: FilledButton.styleFrom(backgroundColor: blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                  child: loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Row(mainAxisSize: MainAxisSize.min, children: [Text(l10n.login), const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded)]),
                ),
              ),
              const SizedBox(height: 26),
              const _OrDivider(),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(child: _SocialButton(label: 'Google', icon: _GoogleMark())),
                  SizedBox(width: 12),
                  Expanded(child: _SocialButton(label: 'Facebook', icon: Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 28))),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccountYet, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66789F))),
                  TextButton(onPressed: loading ? null : () => context.goNamed(AppRouteNames.register), child: Text(l10n.register)),
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
        decoration: BoxDecoration(color: const Color(0xFFFFECEB), borderRadius: BorderRadius.circular(14)),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFB42318))),
      );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or continue with', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66789F)))),
        const Expanded(child: Divider()),
      ]);
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});
  final String label;
  final Widget icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 58,
        child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)), child: Row(mainAxisSize: MainAxisSize.min, children: [icon, const SizedBox(width: 8), Text(label, style: const TextStyle(color: Color(0xFF111B48)))])),
      );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) => const Text('G', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)));
}
