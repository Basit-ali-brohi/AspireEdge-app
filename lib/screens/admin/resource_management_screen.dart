import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/resource_model.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceManagementScreen extends StatefulWidget {
  const ResourceManagementScreen({super.key});

  @override
  State<ResourceManagementScreen> createState() =>
      _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen> {
  List<ResourceModel> _resources = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedType = 'All';

  final Set<String> _bookmarks = {};
  final Set<String> _wishlist = {};

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot snapshot =
      await FirebaseService.instance.resourcesCollection.get();
      List<ResourceModel> resources =
      snapshot.docs.map((doc) => ResourceModel.fromDocument(doc)).toList();
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading resources: $e'),
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
        title: const Text('Resource Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addResource),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadResources),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedType == 'All'),
                      _buildFilterChip('Blog', _selectedType == 'Blog'),
                      _buildFilterChip('EBook', _selectedType == 'EBook'),
                      _buildFilterChip('Video', _selectedType == 'Video'),
                      _buildFilterChip('Template', _selectedType == 'Template'),
                      _buildFilterChip('Gallery', _selectedType == 'Gallery'),
                      _buildFilterChip('Career', _selectedType == 'Career'),
                    ].map((chip) => Padding(
                      padding: const EdgeInsets.only(right: 8), // space between chips
                      child: chip,
                    )).toList(),
                  ),
                )

              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResourcesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) =>
          setState(() => _selectedType = selected ? label : 'All'),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildResourcesList() {
    List<ResourceModel> filteredResources = _resources.where((resource) {
      final q = _searchQuery.toLowerCase();
      bool matchesSearch = q.isEmpty ||
          resource.title.toLowerCase().contains(q) ||
          resource.description.toLowerCase().contains(q) ||
          resource.tags.any((t) => t.toLowerCase().contains(q));
      bool matchesType = _selectedType == 'All' ||
          resource.resourceType.toLowerCase() == _selectedType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();

    if (filteredResources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No resources found',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredResources.length,
      itemBuilder: (context, index) =>
          _buildResourceCard(filteredResources[index]),
    );
  }
  Widget _buildResourceCard(ResourceModel resource) {
    final isBookmarked = _bookmarks.contains(resource.resourceId);
    final inWishlist = _wishlist.contains(resource.resourceId);

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(resource.resourceType),
          child: Icon(_getTypeIcon(resource.resourceType), color: AppColors.white),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              resource.shortDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource.resourceType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: _getTypeColor(resource.resourceType)),
                    ),
                    child: Text(
                      resource.typeDisplayName,
                      style: TextStyle(
                          color: _getTypeColor(resource.resourceType),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    resource.category,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          resource.averageRatingText,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  if (isBookmarked) {
                    _bookmarks.remove(resource.resourceId);
                  } else {
                    _bookmarks.add(resource.resourceId);
                  }
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleResourceAction(value, resource),
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'view',
                    child: Row(children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('View Details')
                    ])),
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Resource')
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Resource',
                          style: TextStyle(color: AppColors.error))
                    ])),
                PopupMenuItem(
                  value: 'wishlist',
                  child: Row(children: [
                    Icon(
                        inWishlist ? Icons.check_circle : Icons.playlist_add,
                        size: 20,
                        color: AppColors.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                          inWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'blog':
        return AppColors.primary;
      case 'ebook':
        return AppColors.success;
      case 'video':
        return AppColors.info;
      case 'template':
        return AppColors.secondary;
      case 'gallery':
        return Colors.purple;
      case 'career':
        return AppColors.professionalColor;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'blog':
        return Icons.article;
      case 'ebook':
        return Icons.book;
      case 'video':
        return Icons.video_library;
      case 'template':
        return Icons.description;
      case 'gallery':
        return Icons.photo_library;
      case 'career':
        return Icons.school;
      default:
        return Icons.library_books;
    }
  }

  void _handleResourceAction(String action, ResourceModel resource) {
    switch (action) {
      case 'view':
        _showResourceDetails(resource);
        break;
      case 'edit':
        _editResource(resource);
        break;
      case 'delete':
        _deleteResource(resource);
        break;
      case 'wishlist':
        setState(() {
          if (_wishlist.contains(resource.resourceId)) {
            _wishlist.remove(resource.resourceId);
          } else {
            _wishlist.add(resource.resourceId);
          }
        });
        break;
    }
  }

  void _showResourceDetails(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', resource.typeDisplayName),
              _buildDetailRow('Category', resource.category),
              _buildDetailRow('Description', resource.description),
              if (resource.author != null) _buildDetailRow('Author', resource.author!),
              if (resource.fileUrl != null) _buildDetailRow('File URL', resource.fileUrl!),
              if (resource.videoUrl != null) _buildDetailRow('Video URL', resource.videoUrl!),
              if (resource.thumbnailUrl != null) _buildDetailRow('Thumbnail', resource.thumbnailUrl!),
              if (resource.tags.isNotEmpty) _buildDetailRow('Tags', resource.tags.join(', ')),
              _buildDetailRow('Rating', resource.averageRatingText),
              _buildDetailRow('Views', resource.viewCount.toString()),
              _buildDetailRow('Created', resource.createdAt.toString()),
              if (resource.resourceType.toLowerCase() == 'career') ...[
                const SizedBox(height: 8),
                _buildDetailRow('Industry', resource.industry ?? 'N/A'),
                _buildDetailRow('Salary', resource.salaryRange ?? 'N/A'),
                _buildDetailRow('Required Skills', (resource.requiredSkills ?? []).join(', ')),
                _buildDetailRow('Education', resource.educationPath ?? 'N/A'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 95,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _addResource() async {
    final newResource = await _showResourceForm();
    if (newResource == null) return;

    try {
      final docRef = FirebaseService.instance.resourcesCollection.doc();
      final resourceWithId = newResource.copyWith(
        resourceId: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(resourceWithId.toMap());
      setState(() => _resources.add(resourceWithId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Resource added successfully!'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add resource: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _editResource(ResourceModel resource) async {
    final updatedResource = await _showResourceForm(resource: resource);
    if (updatedResource == null) return;

    final resourceWithId = updatedResource.copyWith(
      resourceId: resource.resourceId,
      updatedAt: DateTime.now(),
      createdAt: resource.createdAt,
    );

    try {
      await FirebaseService.instance.resourcesCollection
          .doc(resource.resourceId)
          .update(resourceWithId.toMap());

      int index =
      _resources.indexWhere((r) => r.resourceId == resource.resourceId);
      if (index != -1) setState(() => _resources[index] = resourceWithId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Resource updated successfully!'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update resource: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteResource(ResourceModel resource) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete ${resource.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await FirebaseService.instance.resourcesCollection
          .doc(resource.resourceId)
          .delete();
      setState(() => _resources.removeWhere((r) => r.resourceId == resource.resourceId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource deleted successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete resource: $e'), backgroundColor: AppColors.error),
      );
    }
  }
  Future<ResourceModel?> _showResourceForm({ResourceModel? resource}) async {
    final titleController = TextEditingController(text: resource?.title ?? '');
    final descriptionController = TextEditingController(text: resource?.description ?? '');
    final authorController = TextEditingController(text: resource?.author ?? '');
    final categoryController = TextEditingController(text: resource?.category ?? '');
    final thumbnailController = TextEditingController(text: resource?.thumbnailUrl ?? '');
    final fileUrlController = TextEditingController(text: resource?.fileUrl ?? '');
    final videoUrlController = TextEditingController(text: resource?.videoUrl ?? '');
    final tagsController = TextEditingController(text: resource?.tags.join(', ') ?? '');
    final salaryController = TextEditingController(text: resource?.salaryRange ?? '');
    final requiredSkillsController = TextEditingController(text: resource?.requiredSkills?.join(', ') ?? '');
    final educationController = TextEditingController(text: resource?.educationPath ?? '');

    // Corrected logic: Use a fallback value if the resource type is invalid.
    String selectedType = ['Blog', 'EBook', 'Video', 'Template', 'Gallery', 'Career'].contains(resource?.resourceType)
        ? resource?.resourceType ?? 'Blog'
        : 'Blog';

    bool isDownloadable = resource?.isDownloadable ?? false;

    return showDialog<ResourceModel>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(resource == null ? 'Add Resource' : 'Edit Resource'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 8),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  const SizedBox(height: 8),
                  TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),
                  const SizedBox(height: 8),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'Blog', child: Text('Blog')),
                      DropdownMenuItem(value: 'EBook', child: Text('EBook')),
                      DropdownMenuItem(value: 'Video', child: Text('Video')),
                      DropdownMenuItem(value: 'Template', child: Text('Template')),
                      DropdownMenuItem(value: 'Gallery', child: Text('Gallery')),
                      DropdownMenuItem(value: 'Career', child: Text('Career')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setStateDialog(() => selectedType = v);
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: thumbnailController, decoration: const InputDecoration(labelText: 'Thumbnail URL (optional)')),
                  const SizedBox(height: 8),
                  if (selectedType.toLowerCase() == 'video')
                    TextField(controller: videoUrlController, decoration: const InputDecoration(labelText: 'Video URL')),
                  if (selectedType.toLowerCase() != 'video')
                    TextField(controller: fileUrlController, decoration: const InputDecoration(labelText: 'File URL (for downloads)')),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: isDownloadable,
                    onChanged: (v) => setStateDialog(() => isDownloadable = v ?? false),
                    title: const Text('Is Downloadable'),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
                  if (selectedType.toLowerCase() == 'career') ...[
                    const SizedBox(height: 8),
                    TextField(controller: salaryController, decoration: const InputDecoration(labelText: 'Salary Range')),
                    const SizedBox(height: 8),
                    TextField(controller: requiredSkillsController, decoration: const InputDecoration(labelText: 'Required Skills (comma separated)')),
                    const SizedBox(height: 8),
                    TextField(controller: educationController, decoration: const InputDecoration(labelText: 'Education Path')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || descriptionController.text.isEmpty) return;

                  final tags = tagsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final requiredSkills = requiredSkillsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final updatedData = (resource != null)
                      ? resource.copyWith(
                    title: titleController.text,
                    description: descriptionController.text,
                    author: authorController.text.isNotEmpty ? authorController.text : null,
                    category: categoryController.text,
                    resourceType: selectedType,
                    content: (selectedType.toLowerCase() == 'blog') ? descriptionController.text : null,
                    fileUrl: fileUrlController.text.isNotEmpty ? fileUrlController.text : null,
                    videoUrl: videoUrlController.text.isNotEmpty ? videoUrlController.text : null,
                    thumbnailUrl: thumbnailController.text.isNotEmpty ? thumbnailController.text : null,
                    tags: tags,
                    isDownloadable: isDownloadable,
                    // Correctly handle career-specific fields, ensuring nullability
                    industry: (selectedType.toLowerCase() == 'career') ? (salaryController.text.isNotEmpty ? salaryController.text : null) : null,
                    requiredSkills: (selectedType.toLowerCase() == 'career') ? requiredSkills : null,
                    salaryRange: (selectedType.toLowerCase() == 'career') ? (salaryController.text.isNotEmpty ? salaryController.text : null) : null,
                    educationPath: (selectedType.toLowerCase() == 'career') ? (educationController.text.isNotEmpty ? educationController.text : null) : null,
                    updatedAt: DateTime.now(),
                  )
                      : ResourceModel(
                    resourceId: '', // ID will be set later
                    title: titleController.text,
                    description: descriptionController.text,
                    author: authorController.text.isNotEmpty ? authorController.text : null,
                    category: categoryController.text,
                    resourceType: selectedType,
                    content: (selectedType.toLowerCase() == 'blog') ? descriptionController.text : null,
                    fileUrl: fileUrlController.text.isNotEmpty ? fileUrlController.text : null,
                    videoUrl: videoUrlController.text.isNotEmpty ? videoUrlController.text : null,
                    thumbnailUrl: thumbnailController.text.isNotEmpty ? thumbnailController.text : null,
                    tags: tags,
                    isDownloadable: isDownloadable,
                    isBookmarkable: true,
                    isPremium: false,
                    viewCount: 0,
                    downloadCount: 0,
                    rating: 0.0,
                    ratingCount: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isActive: true,
                    // Career-specific fields for new resource
                    industry: selectedType.toLowerCase() == 'career' ? 'N/A' : null,
                    requiredSkills: selectedType.toLowerCase() == 'career' ? requiredSkills : null,
                    salaryRange: selectedType.toLowerCase() == 'career' ? (salaryController.text.isNotEmpty ? salaryController.text : null) : null,
                    educationPath: selectedType.toLowerCase() == 'career' ? (educationController.text.isNotEmpty ? educationController.text : null) : null,
                  );

                  Navigator.of(context).pop(updatedData);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
  }
