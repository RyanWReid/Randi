import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock User class
class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
  });
}

// Mock credential class
class UserCredential {
  final User user;
  UserCredential({required this.user});
}

// Mock Auth Service (for development without Firebase)
class AuthService {
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  // Current user getter
  User? get currentUser => _currentUser;
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation (in a real app, this would be handled by Firebase)
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      // Create mock user
      final user = User(
        uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      
      _currentUser = user;
      _authStateController.add(user);
      
      return UserCredential(user: user);
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple validation
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      // Create mock user
      final user = User(
        uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      
      _currentUser = user;
      _authStateController.add(user);
      
      return UserCredential(user: user);
    } catch (e) {
      debugPrint('Error registering with email: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock Google user
      final user = User(
        uid: 'google-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: 'google-user@example.com',
        displayName: 'Google User',
        photoURL: 'https://ui-avatars.com/api/?name=Google+User&background=random',
      );
      
      _currentUser = user;
      _authStateController.add(user);
      
      return UserCredential(user: user);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // Simple validation
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email format');
      }
      
      // Just simulate success after delay
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

// Regular providers
final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService();
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}); 