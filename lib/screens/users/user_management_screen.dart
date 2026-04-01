import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Force refresh by recreating the stream
  Stream<List<AppUser>> get _usersStream => DatabaseService().getAllUsers();

  void _refreshData() {
    setState(() {
      // Trigger rebuild - stream will emit new data
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Only Admin and Manager can access
    if (authProvider.isShopkeeper) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to manage users'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch ~/
            1000), // Force rebuild on refresh
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(user.username),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.displayName,
                          style: TextStyle(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: authProvider.isAdmin
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditUserDialog(context, user);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, user);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddUserDialog(context),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.shopkeeper:
        return Colors.green;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onUserAdded: _refreshData),
    );
  }

  void _showEditUserDialog(BuildContext context, AppUser user) {
    final usernameController = TextEditingController(text: user.username);
    final nameController = TextEditingController(text: user.name);
    final passwordController = TextEditingController();
    UserRole selectedRole = user.role;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password (leave empty to keep current)',
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Min 3 characters',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 3) {
                      return 'Min 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  value: selectedRole,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (usernameController.text.isEmpty ||
                          nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields')),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        final updateData = <String, dynamic>{
                          'username': usernameController.text.trim(),
                          'name': nameController.text.trim(),
                          'role': selectedRole.value,
                        };

                        if (passwordController.text.isNotEmpty) {
                          updateData['password'] =
                              passwordController.text.trim();
                        }

                        await DatabaseService().updateUser(user.id, updateData);

                        if (context.mounted) {
                          Navigator.pop(context);
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${user.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Username: ${user.username}',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.badge, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${user.role.displayName}',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will deactivate the user account. The user will not be able to login.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseService().deleteUser(user.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final VoidCallback? onUserAdded;

  const AddUserDialog({super.key, this.onUserAdded});
  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.shopkeeper;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.createUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      // Only close dialog and show success if no error occurred
      if (mounted) {
        Navigator.pop(context); // Close dialog
        widget.onUserAdded?.call(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to create user';

      // Handle duplicate username error
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('users_username_key')) {
        errorMessage =
            'Username already exists. Please choose a different username.';
      } else if (e.toString().contains('PostgrestException')) {
        errorMessage = 'Database error. Please try again.';
      }

      // Keep dialog open and show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Don't close the dialog - let user fix the error
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Min 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                value: _selectedRole,
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Add User'),
        ),
      ],
    );
  }
}
