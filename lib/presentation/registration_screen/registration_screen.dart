import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';
import '../../core/app_export.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/registration_form_field.dart';
import './widgets/terms_privacy_links.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isFormValid = false;
  String _emailError = '';
  final String _passwordError = '';
  String _confirmPasswordError = '';
  late SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    supabase = SupabaseService.instance.client;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              _buildHeader(),
              SizedBox(height: 4.h),
              _buildProgressIndicator(),
              SizedBox(height: 4.h),
              _buildRegistrationForm(),
              SizedBox(height: 3.h),
              const TermsPrivacyLinks(),
              SizedBox(height: 4.h),
              _buildCreateAccountButton(),
              SizedBox(height: 3.h),
              _buildLoginLink(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join your team and start collaborating with synchronized calendars',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return const ProgressIndicatorWidget(
      currentStep: 1,
      totalSteps: 2,
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RegistrationFormField(
            label: 'Full Name',
            hint: 'Enter your full name',
            iconName: 'person',
            controller: _fullNameController,
            validator: _validateFullName,
            onChanged: (_) => _validateForm(),
          ),
          SizedBox(height: 3.h),
          RegistrationFormField(
            label: 'Email Address',
            hint: 'Enter your email address',
            iconName: 'email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            onChanged: (_) => _validateForm(),
          ),
          if (_emailError.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _buildErrorMessage(_emailError),
          ],
          SizedBox(height: 3.h),
          RegistrationFormField(
            label: 'Password',
            hint: 'Create a strong password',
            iconName: 'lock',
            controller: _passwordController,
            isPassword: true,
            validator: _validatePassword,
            onChanged: (_) => _validateForm(),
          ),
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            PasswordStrengthIndicator(password: _passwordController.text),
          ],
          SizedBox(height: 3.h),
          RegistrationFormField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            iconName: 'lock',
            controller: _confirmPasswordController,
            isPassword: true,
            validator: _validateConfirmPassword,
            onChanged: (_) => _validateForm(),
          ),
          if (_confirmPasswordError.isNotEmpty) ...[
            SizedBox(height: 1.h),
            _buildErrorMessage(_confirmPasswordError),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'error',
          color: AppTheme.getErrorColor(true),
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getErrorColor(true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _handleCreateAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          elevation: _isFormValid ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
        child: RichText(
          text: TextSpan(
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _validateForm() {
    setState(() {
      _emailError = '';
      _confirmPasswordError = '';
      _isFormValid = _fullNameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _validateFullName(_fullNameController.text) == null &&
          _validateEmail(_emailController.text) == null &&
          _validatePassword(_passwordController.text) == null &&
          _validateConfirmPassword(_confirmPasswordController.text) == null &&
          _emailError.isEmpty &&
          _confirmPasswordError.isEmpty;
    });
  }

  Future<void> _handleCreateAccount() async {
    // Walidacja formularza przed rozpoczęciem operacji
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    // Włączenie wskaźnika ładowania
    setState(() {
      _isLoading = true;
    });

    try {
      // Krok 1: Wykonaj rejestrację w Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _fullNameController.text.trim()},
      );
      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rejestracja udana! Prosimy o sprawdzenie skrzynki e-mail w celu weryfikacji konta.',
              ),
              backgroundColor: AppTheme.getSuccessColor(true),
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } on AuthException catch (e) {
      debugPrint("Auth Exception ${e}");
      if (mounted) {
        String errorMessage = 'Rejestracja nieudana. Spróbuj ponownie.';

        if (e.message.contains('User already registered') ||
            e.message.contains('email already registered')) {
          errorMessage = 'Konto z tym e-mailem już istnieje. Zaloguj się.';
        } else if (e.message.contains('Invalid password')) {
          errorMessage = 'Hasło jest za słabe lub niepoprawne.';
        } else if (e.message.contains('Email link sent')) {
          errorMessage =
              'Link weryfikacyjny został już wysłany. Sprawdź swoją skrzynkę.';
        }

        _showErrorDialog('Błąd rejestracji', errorMessage);
      }
    } catch (e) {
      // Obsługa wszystkich innych, nieprzewidzianych błędów (np. brak internetu)
      if (mounted) {
        // Wypisz błąd do konsoli, aby ułatwić debugowanie
        print('Nieoczekiwany błąd podczas rejestracji: $e');
        _showErrorDialog(
          'Błąd rejestracji',
          'Nie udało się utworzyć konta. Sprawdź swoje połączenie z internetem i spróbuj ponownie.',
        );
      }
    } finally {
      // Wyłączenie wskaźnika ładowania, niezależnie od wyniku operacji
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getErrorColor(true),
            ),
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
