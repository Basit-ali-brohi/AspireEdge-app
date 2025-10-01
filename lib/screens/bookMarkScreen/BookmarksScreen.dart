import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/resource_model.dart';
import '../resources/resource_detail_screen.dart';
import '../../widgets/resource_card.dart';

class BookmarksScreen extends StatelessWidget {
  final String userId; // Login user id required

  const BookmarksScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('bookmarks').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return _buildEmptyState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final bookmarkedIds = data.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();

          if (bookmarkedIds.isEmpty) return _buildEmptyState();

          return FutureBuilder<QuerySnapshot>(
            future: _firestore
                .collection('resources')
                .where('resourceId', whereIn: bookmarkedIds)
                .get(),
            builder: (context, resSnapshot) {
              if (!resSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final resources = resSnapshot.data!.docs
                  .map((doc) => ResourceModel.fromDocument(doc))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  final resource = resources[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ResourceCard(
                      resource: resource,
                      isWishlisted: true,
                      onWishlistToggle: () async {
                        // Remove bookmark
                        await _firestore.collection('bookmarks').doc(userId).set({
                          resource.resourceId: false,
                        }, SetOptions(merge: true));
                      },
                      onTap: () {
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bookmark_border, size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text('No bookmarks found',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
