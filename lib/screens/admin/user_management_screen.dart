import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedTier = 'All';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot snapshot =
      await FirebaseService.instance.firestore.collection('users').get();

      List<UserModel> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Use userId from Firestore doc id
        data['userId'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedTier == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Student', _selectedTier == 'Student'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Graduate', _selectedTier == 'Graduate'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Professional', _selectedTier == 'Professional'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admin', _selectedTier == 'Admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTier = selected ? label : 'All';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildUsersList() {
    List<UserModel> filteredUsers = _users.where((user) {
      bool matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesTier = _selectedTier == 'All' || user.tier == _selectedTier;
      return matchesSearch && matchesTier;
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        UserModel user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getTierColor(user.tier).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTierColor(user.tier)),
              ),
              child: Text(user.tier,
                  style: TextStyle(color: _getTierColor(user.tier), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [Icon(Icons.visibility, size: 20), SizedBox(width: 8), Text('View Details')],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit User')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete User', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'student':
        return AppColors.primary;
      case 'graduate':
        return AppColors.success;
      case 'professional':
        return AppColors.info;
      case 'admin':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', user.name),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phone),
            _buildDetailRow('Tier', user.tier),
            _buildDetailRow('Created', user.createdAt.toString()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editUser(UserModel user) {
    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController emailController = TextEditingController(text: user.email);
    TextEditingController phoneController = TextEditingController(text: user.phone);
    String tier = user.tier;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              DropdownButtonFormField<String>(
                value: tier,
                items: ['Student', 'Graduate', 'Professional', 'Admin']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => tier = val ?? tier,
                decoration: const InputDecoration(labelText: 'Tier'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final updatedUser = user.copyWith(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                tier: tier,
                updatedAt: DateTime.now(),
              );
              try {
                await FirebaseService.instance.firestore
                    .collection('users')
                    .doc(user.userId)
                    .update(updatedUser.toMap());
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating user: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseService.instance.firestore.collection('users').doc(user.userId).delete();
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting user: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
