import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randi/core/services/auth_service.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMsg = useState<String?>(null);
    
    // Register with email and password
    Future<void> _signUp() async {
      // Validate input
      if (nameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          passwordController.text.isEmpty) {
        errorMsg.value = 'Please fill in all fields';
        return;
      }
      
      if (passwordController.text != confirmPasswordController.text) {
        errorMsg.value = 'Passwords do not match';
        return;
      }
      
      if (passwordController.text.length < 6) {
        errorMsg.value = 'Password must be at least 6 characters';
        return;
      }

      try {
        isLoading.value = true;
        errorMsg.value = null;
        
        await ref.read(authServiceProvider).registerWithEmail(
          emailController.text.trim(),
          passwordController.text,
        );
        
        // Update user profile with name
        // This would be handled in a more complete implementation
        
        if (context.mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        errorMsg.value = 'Failed to create account: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              // Password field
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                enabled: !isLoading.value,
              ),
              const SizedBox(height: 16),
              // Confirm password field
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !isLoading.value,
                onSubmitted: (_) => _signUp(),
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
              // Sign up button
              ElevatedButton(
                onPressed: isLoading.value ? null : _signUp,
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
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              // Terms and privacy policy
              const Text(
                'By signing up, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: isLoading.value
                        ? null
                        : () => context.push('/signin'),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 