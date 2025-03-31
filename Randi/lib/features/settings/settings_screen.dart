import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randi/core/providers/user_profile_provider.dart';
import 'package:randi/core/services/auth_service.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final isDarkMode = useState(Theme.of(context).brightness == Brightness.dark);
    final isLoading = useState(false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Controllers for editing profile
    final nameController = useTextEditingController(text: userProfile?.name ?? '');
    final emailController = useTextEditingController(text: userProfile?.email ?? '');
    final companyController = useTextEditingController(text: userProfile?.company ?? '');
    final phoneController = useTextEditingController(text: userProfile?.phone ?? '');
    
    // Save profile changes
    void saveProfile() {
      if (userProfile == null) return;
      
      ref.read(userProfileProvider.notifier).updateProfile(
        name: nameController.text,
        company: companyController.text,
        phone: phoneController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    // Sign out
    Future<void> signOut() async {
      isLoading.value = true;
      try {
        await ref.read(authServiceProvider).signOut();
        if (context.mounted) {
          context.go('/welcome');
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: userProfile == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Profile section
                  _buildSectionHeader(context, 'Profile'),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile picture
                          GestureDetector(
                            onTap: () {
                              // In a real app, we would implement image picking
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile picture update not implemented in this demo'),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      userProfile.photoUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userProfile.name)}&background=random',
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Name field
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter your name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Email field (disabled)
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                            ),
                            enabled: false, // Email can't be changed
                          ),
                          const SizedBox(height: 16),
                          // Company field
                          TextField(
                            controller: companyController,
                            decoration: const InputDecoration(
                              labelText: 'Company',
                              hintText: 'Enter your company name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Phone field
                          TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              hintText: 'Enter your phone number',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          // Save button
                          ElevatedButton(
                            onPressed: saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text('Save Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App settings section
                  _buildSectionHeader(context, 'App Settings'),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Theme toggle
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Switch between light and dark theme'),
                          value: isDarkMode.value,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            isDarkMode.value = value;
                            // In a real app, we would update the theme
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Theme switching not implemented in this demo'),
                              ),
                            );
                          },
                          secondary: Icon(
                            isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                            color: isDarkMode.value ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        const Divider(),
                        // Notifications toggle
                        SwitchListTile(
                          title: const Text('Notifications'),
                          subtitle: const Text('Enable or disable push notifications'),
                          value: userProfile.preferences['notifications'] ?? true,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            ref.read(userProfileProvider.notifier).updatePreference('notifications', value);
                          },
                          secondary: Icon(
                            Icons.notifications,
                            color: (userProfile.preferences['notifications'] ?? true) 
                                ? Theme.of(context).colorScheme.primary 
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Info section
                  _buildSectionHeader(context, 'App Info'),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('About'),
                          subtitle: const Text('Learn more about this app'),
                          leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to about screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Terms of Service'),
                          subtitle: const Text('Review our terms'),
                          leading: const Icon(Icons.description),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to terms screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Privacy Policy'),
                          subtitle: const Text('Review our privacy policy'),
                          leading: const Icon(Icons.privacy_tip),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to privacy policy screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Version'),
                          subtitle: const Text('1.0.0 (Build 1)'),
                          leading: Icon(Icons.info_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account actions section
                  _buildSectionHeader(context, 'Account'),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Change Password'),
                          leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to change password screen
                          },
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Sign Out'),
                          leading: Icon(Icons.logout, color: Colors.redAccent),
                          onTap: isLoading.value ? null : signOut,
                          trailing: isLoading.value 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                ) 
                              : const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
} 