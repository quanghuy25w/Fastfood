import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
    await authProvider.register(
      User(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
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
      appBar: AppBar(title: const Text('Dang ky tai khoan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colors.secondaryContainer,
              ),
              child: Text(
                'Tạo tài khoản để đặt món và theo dÕi đơn hàng nhanh hơn.',
                style: Theme.of(context).textTheme.bodyLarge,
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
                        controller: _nameController,
                        labelText: 'Ho ten',
                        hintText: 'Nhap ho ten',
                        prefixIcon: const Icon(Icons.person_outline),
                        textInputAction: TextInputAction.next,
                        validator: (value) => AppValidators.requiredField(
                          value,
                          fieldName: 'ho ten',
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Nhap email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Mat khau',
                        hintText: 'Mat khau toi thieu 6 ky tu',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        validator: AppValidators.password,
                      ),
                      const SizedBox(height: 18),
                      CustomButton.primary(
                        text: 'Dang ky',
                        onPressed: _submit,
                        isLoading: authProvider.isLoading,
                        fullWidth: true,
                        leadingIcon: const Icon(Icons.app_registration),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          AppHelpers.pop(context);
                        },
                        child: const Text('Da co tai khoan? Dang nhap'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
