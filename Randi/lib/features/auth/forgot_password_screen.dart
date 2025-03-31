import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randi/core/services/auth_service.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isLoading = useState(false);
    final errorMsg = useState<String?>(null);
    final isResetEmailSent = useState(false);
    
    // Send password reset email
    Future<void> _resetPassword() async {
      if (emailController.text.trim().isEmpty) {
        errorMsg.value = 'Please enter your email';
        return;
      }

      try {
        isLoading.value = true;
        errorMsg.value = null;
        
        await ref.read(authServiceProvider).resetPassword(
          emailController.text.trim(),
        );
        
        isResetEmailSent.value = true;
      } catch (e) {
        errorMsg.value = 'Failed to send reset email: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isResetEmailSent.value) ...[
                const Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Email field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading.value,
                  onSubmitted: (_) => _resetPassword(),
                ),
                const SizedBox(height: 24),
                // Error message
                if (errorMsg.value != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMsg.value!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                // Reset button
                ElevatedButton(
                  onPressed: isLoading.value ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send Reset Link'),
                ),
              ] else ...[
                // Success message
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reset Link Sent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We\'ve sent a password reset link to ${emailController.text.trim()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your email and follow the instructions to reset your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/signin'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Back to Sign In'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 