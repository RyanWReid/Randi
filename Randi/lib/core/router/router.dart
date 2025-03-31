import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randi/features/dashboard/dashboard_screen.dart';
import 'package:randi/features/cad_generation/cad_generation_screen.dart';
import 'package:randi/features/quote/quote_screen.dart';
import 'package:randi/features/settings/settings_screen.dart';
import 'package:randi/features/auth/welcome_screen.dart';
import 'package:randi/features/auth/signin_screen.dart';
import 'package:randi/features/auth/signup_screen.dart';
import 'package:randi/features/auth/forgot_password_screen.dart';
import 'package:randi/core/services/auth_service.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show bottom navigation on auth screens or settings
    final bool showBottomNav = !currentPath.startsWith('/signin') && 
                              !currentPath.startsWith('/signup') && 
                              !currentPath.startsWith('/welcome') &&
                              !currentPath.startsWith('/forgot-password') &&
                              !currentPath.startsWith('/settings');
    
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav 
          ? BottomNavigationBar(
              currentIndex: _getSelectedIndex(currentPath),
              onTap: (index) => _onItemTapped(index, context),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade400 
                  : Colors.grey.shade600,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF1E1E1E)
                  : Colors.white,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt),
                  label: 'CAD Gen',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate),
                  label: 'Quote',
                ),
              ],
            )
          : null,
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/cad-generation')) return 1;
    if (path.startsWith('/quote')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/cad-generation');
        break;
      case 2:
        context.go('/quote');
        break;
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/welcome',
    
    // Global redirect handler
    redirect: (context, state) {
      // Handle auth state redirects
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLoginPage = state.matchedLocation.startsWith('/signin') || 
                           state.matchedLocation.startsWith('/signup') ||
                           state.matchedLocation.startsWith('/welcome') ||
                           state.matchedLocation.startsWith('/forgot-password');
      
      // If not logged in and not on a login page, redirect to welcome
      if (!isLoggedIn && !isOnLoginPage) {
        return '/welcome';
      }
      
      // If logged in and on a login page, redirect to dashboard
      if (isLoggedIn && isOnLoginPage) {
        return '/dashboard';
      }
      
      // No redirect needed
      return null;
    },
    
    // Error handler
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error?.toString() ?? "Page not found"}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main app routes (with shell)
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            child: child,
            currentPath: state.uri.path,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/cad-generation',
            name: 'cad-generation',
            builder: (context, state) => const CadGenerationScreen(),
          ),
          GoRoute(
            path: '/quote',
            name: 'quote',
            builder: (context, state) => const QuoteScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}); 