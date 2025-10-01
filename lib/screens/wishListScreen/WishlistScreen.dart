import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/resource_model.dart';
import '../resources/resource_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final String? userId;

  const WishlistScreen({super.key, this.userId});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => widget.userId ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('wishlists').doc(_uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading wishlist: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            if (data == null || data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.favorite_border,
                        size: 80, color: AppColors.textHint),
                    SizedBox(height: 16),
                    Text('Your wishlist is empty',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            final resourceIds = data.keys.toList();

            return ListView.builder(
              itemCount: resourceIds.length,
              itemBuilder: (context, index) {
                final resourceId = resourceIds[index];

                return FutureBuilder<DocumentSnapshot>(
                  future:
                  _firestore.collection('resources').doc(resourceId).get(),
                  builder: (context, resourceSnapshot) {
                    if (!resourceSnapshot.hasData ||
                        !resourceSnapshot.data!.exists) {
                      return const ListTile(
                        title: Text('Loading...'),
                        leading: Icon(Icons.book),
                      );
                    }

                    final resourceDoc = resourceSnapshot.data!;
                    final resource = ResourceModel.fromDocument(resourceDoc);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: ListTile(
                        leading: resource.thumbnailUrl != null
                            ? Image.network(resource.thumbnailUrl!,
                            width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.book),
                        title: Text(resource.title),
                        subtitle: Text(resource.typeDisplayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () async {
                            await _firestore
                                .collection('wishlists')
                                .doc(_uid)
                                .update({resourceId: FieldValue.delete()});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from wishlist"),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          // Navigate to Resource Detail Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResourceDetailScreen(resource: resource),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
