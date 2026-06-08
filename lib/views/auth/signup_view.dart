import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              colorScheme.secondary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: ResponsiveCenter(
                    maxWidth: 560,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopBar(context),
                          SizedBox(height: 22),
                          _buildHeader(context),
                          SizedBox(height: 24),
                          _buildFormPanel(context),
                          SizedBox(height: 16),
                          _buildLoginLink(context),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton.filledTonal(
        tooltip: 'Back',
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.checkroom_outlined,
            size: 38,
            color: colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: 22),
        Text(
          'Create your customer account',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Save measurements, manage designs, track wardrobe items, and view payments from one polished customer dashboard.',
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildFeaturePill(
              context,
              icon: Icons.straighten_outlined,
              label: 'Measurements',
            ),
            _buildFeaturePill(
              context,
              icon: Icons.style_outlined,
              label: 'Wardrobe',
            ),
            _buildFeaturePill(
              context,
              icon: Icons.payments_outlined,
              label: 'Payments',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturePill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: colorScheme.primary),
            SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Account details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Customer account',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildFields(),
            SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Full Name',
          hintText: 'Enter your full name',
          controller: _nameController,
          prefixIcon: Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        SizedBox(height: 18),
        CustomTextField(
          label: 'Email Address',
          hintText: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(Icons.email_outlined),
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: 18),
        CustomTextField(
          label: 'Password',
          hintText: 'Enter your password',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: Icon(Icons.lock_outline),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 18),
        CustomTextField(
          label: 'Confirm Password',
          hintText: 'Confirm your password',
          controller: _confirmPasswordController,
          obscureText: true,
          prefixIcon: Icon(Icons.lock_outline),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return CustomButton(
          text: 'Create Account',
          icon: Icons.arrow_forward,
          isLoading: viewModel.isBusy,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await viewModel.signup(
                _nameController.text.trim(),
                _emailController.text.trim(),
                _passwordController.text,
              );
              if (!mounted) return;

              if (success) {
                navigator.pushReplacementNamed('/home');
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(color: Colors.grey[700]),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
