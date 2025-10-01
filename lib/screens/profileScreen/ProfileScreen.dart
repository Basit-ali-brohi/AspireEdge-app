import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../auth/login_screen.dart';
import '../bookMarkScreen/BookmarksScreen.dart';
import '../wishListScreen/WishlistScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final cloudinary = CloudinaryPublic('dwex8wj8e', 'flutter_upload1', cache: false);

  File? _profileImage;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }

  Future<void> _loadUserImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null && doc.data()!['photoUrl'] != null) {
      setState(() {
        _imageUrl = doc.data()!['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadImage(_profileImage!);
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      setState(() => _isUploading = true);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'user_profiles'),
      );

      final downloadUrl = response.secureUrl;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'photoUrl': downloadUrl},
        SetOptions(merge: true),
      );

      setState(() => _imageUrl = downloadUrl);
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      return null;
    } finally {
      setState(() => _isUploading = false);
      _profileImage = null;
    }
  }

  Future<void> _editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName ?? '');
    final emailController = TextEditingController(text: user.email ?? '');
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_imageUrl != null
                          ? CachedNetworkImageProvider(_imageUrl!)
                          : null) as ImageProvider<Object>?,
                      child: _profileImage == null && _imageUrl == null
                          ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                          : null,
                    ),
                  ),
                  if (_isUploading)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 12),
              TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Old Password")),
              TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                String? imageUrl;
                if (_profileImage != null) {
                  imageUrl = await _uploadImage(_profileImage!);
                }

                await user.updateDisplayName(nameController.text);
                if (user.email != emailController.text) await user.updateEmail(emailController.text);

                if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                  final cred =
                  EmailAuthProvider.credential(email: user.email!, password: oldPasswordController.text);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPasswordController.text);
                }

                await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
                  {
                    'name': nameController.text,
                    'email': emailController.text,
                    'photoUrl': imageUrl ?? _imageUrl,
                    'updatedAt': DateTime.now(),
                  },
                  SetOptions(merge: true),
                );

                await user.reload();
                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_imageUrl != null
                            ? CachedNetworkImageProvider(_imageUrl!)
                            : null) as ImageProvider<Object>?,
                        child: _profileImage == null && _imageUrl == null
                            ? Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'User',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(user?.email ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppColors.primary),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _editProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite, color: AppColors.error),
                    title: const Text('Wishlist'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WishlistScreen(userId: user.uid)), // ✅ Fixed
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bookmark, color: AppColors.accent),
                    title: const Text('Bookmarks'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookmarksScreen(userId: user.uid)), // ✅ Fixed
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
