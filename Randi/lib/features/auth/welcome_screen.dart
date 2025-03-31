import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WelcomeScreen extends HookConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo and app name
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.precision_manufacturing,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Randi Metal Fabrication',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CAD Generation & Quote System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Welcome text
              const Text(
                'Welcome to the future of metal fabrication. Turn photos into CAD designs and get instant quotes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Sign in button
              ElevatedButton(
                onPressed: () => context.push('/signin'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              // Register button
              OutlinedButton(
                onPressed: () => context.push('/signup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 24),
              // Continue as guest
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Continue as Guest'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 