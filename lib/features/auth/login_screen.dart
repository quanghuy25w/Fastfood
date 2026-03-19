import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppHelpers.dismissKeyboard(context);

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (authProvider.currentUser != null) {
      AppHelpers.pushNamedAndRemoveUntil(context, AppRoutes.dashboard);
      return;
    }

    if (authProvider.errorMessage != null) {
      AppHelpers.showErrorSnackBar(context, authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withValues(alpha: 0.84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dang nhap de dat mon nhanh hon',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Nhap email cua ban',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: AppValidators.email,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Mat khau',
                          hintText: 'Nhap mat khau',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) => AppValidators.requiredField(
                            value,
                            fieldName: 'mat khau',
                          ),
                        ),
                        const SizedBox(height: 18),
                        CustomButton.primary(
                          text: 'Dang nhap',
                          onPressed: _submit,
                          isLoading: authProvider.isLoading,
                          fullWidth: true,
                          leadingIcon: const Icon(Icons.login),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            AppHelpers.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text('Chúa có tài khoản? Đăng ký'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
