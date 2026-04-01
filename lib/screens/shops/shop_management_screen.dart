import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';

class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({super.key});

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<AppUser> _users = [];

  // Force refresh by recreating streams
  Stream<List<Shop>> get _shopsStream => _databaseService.getAllShops();
  Stream<List<AppUser>> get _usersStream => _databaseService.getAllUsers();

  void _refreshData() {
    setState(() {
      // Trigger rebuild - streams will emit new data
      _loadUsers();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _databaseService.getAllUsers().first;
      setState(() => _users = users);
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Admin has full access, Manager can add/edit (no delete)
        final canAdd = authProvider.isAdmin || authProvider.isManager;
        final canDelete = authProvider.isAdmin;
        final canEdit = authProvider.isAdmin || authProvider.isManager;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shop Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
                tooltip: 'Refresh',
              ),
              if (authProvider.isAdmin)
                IconButton(
                  icon: const Icon(Icons.people),
                  tooltip: 'Assign Staff to Shops',
                  onPressed: () => _showAssignStaffDialog(context),
                ),
            ],
          ),
          body: StreamBuilder<List<Shop>>(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch ~/ 1000),
            stream: _shopsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final shops = snapshot.data ?? [];

              if (shops.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No shops added yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (canAdd) ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showAddShopDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Shop'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            shop.shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              if (shop.location != null &&
                                  shop.location!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      shop.location!,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              if (shop.managerName != null &&
                                  shop.managerName!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      shop.managerName!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit' && canEdit) {
                                _showEditShopDialog(context, shop);
                              } else if (value == 'delete' && canDelete) {
                                _showDeleteConfirmation(context, shop);
                              } else if (value == 'assign') {
                                _showAssignShopStaffDialog(context, shop);
                              }
                            },
                            itemBuilder: (context) => [
                              if (canEdit)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit Shop'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'assign',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_add, size: 20),
                                    SizedBox(width: 8),
                                    Text('Assign Staff'),
                                  ],
                                ),
                              ),
                              if (canDelete)
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
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddShopDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Shop'),
                )
              : null,
        );
      },
    );
  }

  void _showAddShopDialog(BuildContext context) {
    final shopNameController = TextEditingController();
    final locationController = TextEditingController();
    final managerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name *',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: managerController,
                decoration: const InputDecoration(
                  labelText: 'Manager Name',
                  prefixIcon: Icon(Icons.person),
                ),
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
            onPressed: () async {
              if (shopNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter shop name')),
                );
                return;
              }

              final shop = Shop(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                shopName: shopNameController.text.trim(),
                location: locationController.text.trim().isEmpty
                    ? null
                    : locationController.text.trim(),
                managerName: managerController.text.trim().isEmpty
                    ? null
                    : managerController.text.trim(),
                createdDate: DateTime.now(),
              );

              await _databaseService.createShop(shop);

              if (context.mounted) {
                Navigator.pop(context);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Shop'),
          ),
        ],
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, Shop shop) {
    final shopNameController = TextEditingController(text: shop.shopName);
    final locationController = TextEditingController(text: shop.location ?? '');
    final managerController =
        TextEditingController(text: shop.managerName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name *',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: managerController,
                decoration: const InputDecoration(
                  labelText: 'Manager Name',
                  prefixIcon: Icon(Icons.person),
                ),
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
            onPressed: () async {
              if (shopNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter shop name')),
                );
                return;
              }

              await _databaseService.updateShop(shop.id, {
                'shopname': shopNameController.text.trim(),
                'location': locationController.text.trim().isEmpty
                    ? null
                    : locationController.text.trim(),
                'managername': managerController.text.trim().isEmpty
                    ? null
                    : managerController.text.trim(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Shop'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${shop.shopName}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will soft delete the shop. Sales data will remain intact.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
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
              await _databaseService.deleteShop(shop.id);

              if (context.mounted) {
                Navigator.pop(context);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
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

  void _showAssignShopStaffDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Staff - ${shop.shopName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a user to assign as shopkeeper for this shop:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (_users.isEmpty)
                const Text(
                  'No users found. Please create users first.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._users
                    .where((user) => user.role == UserRole.shopkeeper)
                    .map((user) => ListTile(
                          leading: CircleAvatar(
                            child: Text(user.name[0].toUpperCase()),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.username),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle),
                            onPressed: () async {
                              await _databaseService.updateUser(user.id, {
                                'shopid': shop.id,
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${user.name} assigned to ${shop.shopName}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ))
                    .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAssignStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Staff to Shops'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create new staff accounts or manage existing ones:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddUserDialog(context);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Create New User'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Existing Users:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<AppUser>>(
                stream: _databaseService.getAllUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final users = snapshot.data!;
                  if (users.isEmpty) {
                    return const Text('No users found');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user.name[0].toUpperCase()),
                        ),
                        title: Text(user.name),
                        subtitle:
                            Text('${user.role.displayName} - ${user.username}'),
                        trailing: user.shopId != null
                            ? Chip(
                                label: Text(
                                  'Shop: ${user.shopId}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.zero,
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.shopkeeper;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: UserRole.shopkeeper,
                      child: const Text('Shopkeeper'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.manager,
                      child: const Text('Manager'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
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
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    usernameController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final user = AppUser(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  username: usernameController.text.trim(),
                  password: passwordController.text.trim(),
                  role: selectedRole,
                  shopId: null,
                  isActive: true,
                );

                try {
                  await _databaseService.createUser(user);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUsers();
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
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
