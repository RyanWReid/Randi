import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:randi/core/services/auth_service.dart';

// User profile model
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? company;
  final String? phone;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.company,
    this.phone,
    Map<String, dynamic>? preferences,
  }) : preferences = preferences ?? {};

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? company,
    String? phone,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      preferences: preferences ?? this.preferences,
    );
  }
}

// Provider that creates a UserProfile from the authenticated User
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return UserProfileNotifier(
    ref,
    authState.value,
  );
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref _ref;
  
  UserProfileNotifier(this._ref, User? user) : super(null) {
    if (user != null) {
      state = UserProfile(
        uid: user.uid,
        name: user.displayName ?? user.email.split('@').first,
        email: user.email,
        photoUrl: user.photoURL ?? _getDefaultAvatarUrl(user.displayName ?? user.email.split('@').first),
      );
    }
    
    // Listen to auth state changes to update profile
    _ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        final user = next.value!;
        state = UserProfile(
          uid: user.uid,
          name: user.displayName ?? user.email.split('@').first,
          email: user.email,
          photoUrl: user.photoURL ?? _getDefaultAvatarUrl(user.displayName ?? user.email.split('@').first),
        );
      } else {
        state = null;
      }
    });
  }
  
  // Update user profile information
  void updateProfile({
    String? name,
    String? photoUrl,
    String? company,
    String? phone,
  }) {
    if (state == null) return;
    
    state = state!.copyWith(
      name: name,
      photoUrl: photoUrl,
      company: company,
      phone: phone,
    );
    
    // In a real app, we would save this data to a backend
  }
  
  // Update user preferences
  void updatePreference(String key, dynamic value) {
    if (state == null) return;
    
    final updatedPreferences = Map<String, dynamic>.from(state!.preferences);
    updatedPreferences[key] = value;
    
    state = state!.copyWith(preferences: updatedPreferences);
    
    // In a real app, we would save this data to a backend
  }
  
  // Generate a default avatar URL based on name
  String _getDefaultAvatarUrl(String name) {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&size=256';
  }
} 