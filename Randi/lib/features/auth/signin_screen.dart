import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randi/core/services/auth_service.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMsg = useState<String?>(null);
    
    // Sign in with email and password
    Future<void> _signInWithEmail() async {
      if (emailController.text.trim().isEmpty ||
          passwordController.text.isEmpty) {
        errorMsg.value = 'Please enter email and password';
        return;
      }

      try {
        isLoading.value = true;
        errorMsg.value = null;
        
        await ref.read(authServiceProvider).signInWithEmail(
          emailController.text.trim(),
          passwordController.text,
        );
        
        if (context.mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        errorMsg.value = 'Failed to sign in: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }
    
    // Sign in with Google
    Future<void> _signInWithGoogle() async {
      try {
        isLoading.value = true;
        errorMsg.value = null;
        
        final userCredential = await ref.read(authServiceProvider).signInWithGoogle();
        
        if (userCredential != null && context.mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        errorMsg.value = 'Failed to sign in with Google: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !isLoading.value,
                onSubmitted: (_) => _signInWithEmail(),
              ),
              const SizedBox(height: 8),
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading.value 
                      ? null 
                      : () => context.push('/forgot-password'),
                  child: const Text('Forgot Password?'),
                ),
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
              // Sign in button
              ElevatedButton(
                onPressed: isLoading.value ? null : _signInWithEmail,
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
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              // Or divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // Google sign in button
              OutlinedButton.icon(
                onPressed: isLoading.value ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const Spacer(),
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: isLoading.value
                        ? null
                        : () => context.push('/signup'),
                    child: const Text('Create Account'),
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