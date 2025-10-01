// ResourcesScreen.dart (wishlist + bookmark-enabled, null-safe, Firebase Auth)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/resource_model.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/resource_card.dart';
import '../../widgets/search_bar_widget.dart';
import 'resource_detail_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<ResourceModel> _allResources = [];
  List<ResourceModel> _filteredResources = [];
  bool _isLoading = true;
  String _selectedType = 'All';
  String _selectedCategory = 'All';
  String _sortBy = 'createdAt';
  bool _isAscending = false;

  Map<String, bool> _wishlistMap = {};
  Map<String, bool> _bookmarkMap = {}; // ✅ Bookmarks map

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadResources();
    _loadWishlist();
    _loadBookmarks(); // ✅ Load bookmarks
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('resources').get();

      _allResources =
          snapshot.docs.map((doc) => ResourceModel.fromDocument(doc)).toList();

      _filteredResources = List.from(_allResources);
      _filterResources();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading resources: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Load wishlist from Firestore
  Future<void> _loadWishlist() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
    await FirebaseFirestore.instance.collection('wishlists').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _wishlistMap = data.map((key, value) => MapEntry(key, value as bool));
      });
    }
  }

  // ✅ Load bookmarks from Firestore
  Future<void> _loadBookmarks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
    await FirebaseFirestore.instance.collection('bookmarks').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _bookmarkMap = data.map((key, value) => MapEntry(key, value as bool));
      });
    }
  }

  // ✅ Toggle wishlist
  Future<void> _toggleWishlist(ResourceModel resource) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final isWishlisted = _wishlistMap[resource.resourceId] ?? false;

    setState(() {
      _wishlistMap[resource.resourceId] = !isWishlisted;
    });

    await FirebaseFirestore.instance
        .collection('wishlists')
        .doc(uid)
        .set({resource.resourceId: !isWishlisted}, SetOptions(merge: true));
  }

  // ✅ Toggle bookmark
  Future<void> _toggleBookmark(ResourceModel resource) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final isBookmarked = _bookmarkMap[resource.resourceId] ?? false;

    setState(() {
      _bookmarkMap[resource.resourceId] = !isBookmarked;
    });

    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(uid)
        .set({resource.resourceId: !isBookmarked}, SetOptions(merge: true));
  }

  void _filterResources() {
    setState(() {
      _filteredResources = _allResources.where((resource) {
        final matchesSearch = resource.title
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
            resource.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            resource.tags.any((tag) => tag
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()));

        final matchesType =
            _selectedType == 'All' || resource.resourceType == _selectedType;

        final matchesCategory =
            _selectedCategory == 'All' || resource.category == _selectedCategory;

        return matchesSearch && matchesType && matchesCategory;
      }).toList();

      _sortResources();
    });
  }

  void _sortResources() {
    _filteredResources.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'rating':
          comparison = (a.rating).compareTo(b.rating);
          break;
        case 'viewCount':
          comparison = (a.viewCount).compareTo(b.viewCount);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedIndustry: _selectedType,
        sortBy: _sortBy,
        isAscending: _isAscending,
        onApply: (industry, sortBy, isAscending) {
          setState(() {
            _selectedType = industry;
            _sortBy = sortBy;
            _isAscending = isAscending;
          });
          _filterResources();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.all_inclusive)),
            Tab(text: 'Blogs', icon: Icon(Icons.article)),
            Tab(text: 'Videos', icon: Icon(Icons.play_circle)),
            Tab(text: 'E-Books', icon: Icon(Icons.book)),
            Tab(text: 'Gallery', icon: Icon(Icons.school)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search resources...',
              onChanged: (value) => _filterResources(),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', _selectedType == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Blog', _selectedType == 'Blog'),
                const SizedBox(width: 8),
                _buildFilterChip('Video', _selectedType == 'Video'),
                const SizedBox(width: 8),
                _buildFilterChip('EBook', _selectedType == 'EBook'),
                const SizedBox(width: 8),
                _buildFilterChip('Gallery', _selectedType == 'Gallery'),
                const SizedBox(width: 8),
                _buildFilterChip('Career', _selectedType == 'Career'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredResources.length} resources found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterBottomSheet,
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(_sortBy == 'title'
                      ? 'Name'
                      : _sortBy == 'createdAt'
                      ? 'Date'
                      : _sortBy == 'rating'
                      ? 'Rating'
                      : 'Views'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResourcesList(),
                _buildResourcesList('Blog'),
                _buildResourcesList('Video'),
                _buildResourcesList('EBook'),
                _buildResourcesList('Career'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList([String? type]) {
    final resources = type != null
        ? _filteredResources.where((r) => r.resourceType == type).toList()
        : _filteredResources;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (resources.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        final isWishlisted = _wishlistMap[resource.resourceId] ?? false;
        final isBookmarked = _bookmarkMap[resource.resourceId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ResourceCard(
            resource: resource,
            isWishlisted: isWishlisted,
            onWishlistToggle: () => _toggleWishlist(resource),
            isBookmarked: isBookmarked,
            onBookmarkToggle: () => _toggleBookmark(resource),
            onTap: () {
              Navigator.of(context).push(
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
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? label : 'All';
        });
        _filterResources();
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No resources found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedType = 'All';
                _selectedCategory = 'All';
              });
              _filterResources();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
