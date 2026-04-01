import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/user_role.dart';
import 'dashboard_screen.dart';
import 'sales/shop_sales_screen.dart';
import 'purchase/purchase_screen.dart';
import 'distribution/distribution_screen.dart';
import 'users/user_management_screen.dart';
import 'shops/shop_management_screen.dart';
import 'reports/reports_home_screen.dart';
import 'notifications_screen.dart';
import 'shopkeeper/shopkeeper_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, _) {
        // Redirect shopkeepers to simplified home screen
        if (authProvider.isShopkeeper) {
          return const ShopkeeperHomeScreen();
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Shop Management'),
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            actions: [
              // Reports icon (Admin/Manager only)
              if (authProvider.isManager || authProvider.isAdmin)
                IconButton(
                  icon: const Icon(Icons.assessment),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 6;
                    });
                  },
                  tooltip: 'Reports',
                ),
              // Notification bell
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount > 9 ? '9+' : notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // User menu
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authProvider.currentUser?.name ?? 'User'),
                        Text(
                          authProvider.currentUser?.role.displayName ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo at the top
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User info below logo
                      Text(
                        authProvider.currentUser?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authProvider.currentUser?.role.displayName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                _buildDrawerItem(Icons.store, 'Shop', 1),
                if (authProvider.isManager || authProvider.isAdmin)
                  _buildDrawerItem(Icons.shopping_cart, 'Purchase', 2),
                if (authProvider.isManager || authProvider.isAdmin)
                  _buildDrawerItem(Icons.local_shipping, 'Distribution', 3),
                if (authProvider.isManager || authProvider.isAdmin)
                  _buildDrawerItem(Icons.people, 'User Management', 4),
                if (authProvider.isAdmin)
                  _buildDrawerItem(Icons.store, 'Shop Management', 5),
                if (authProvider.isManager || authProvider.isAdmin)
                  _buildDrawerItem(Icons.assessment, 'Reports', 6),
              ],
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              const DashboardScreen(),
              const ShopSalesScreen(),
              const PurchaseScreen(),
              const DistributionScreen(),
              const UserManagementScreen(),
              const ShopManagementScreen(),
              const ReportsHomeScreen(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
