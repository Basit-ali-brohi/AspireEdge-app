import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class AdminMultimediaScreen extends StatefulWidget {
  const AdminMultimediaScreen({super.key});

  @override
  State<AdminMultimediaScreen> createState() => _AdminMultimediaScreenState();
}

class _AdminMultimediaScreenState extends State<AdminMultimediaScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final CollectionReference _videos = FirebaseFirestore.instance.collection('multimedia');

  // New State Variables for Type and Tags
  String _selectedType = 'Video';
  List<String> _selectedTags = [];
  final List<String> _mediaTypes = ['Video', 'Podcast'];
  final List<String> _tags = ['Experts', 'Career Talks', 'Student Panels'];

  // Add/Edit Dialog
  void _showMediaDialog({DocumentSnapshot? doc}) {
    bool isEditing = doc != null;
    if (isEditing) {
      final data = doc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _urlController.text = data['url'] ?? '';
      _selectedType = data['type'] ?? 'Video';
      _selectedTags = List<String>.from(data['tags'] ?? []);
    } else {
      _titleController.clear();
      _urlController.clear();
      _selectedType = 'Video';
      _selectedTags = [];
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Media" : "Add New Media"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(labelText: 'URL'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: _mediaTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) => setStateInDialog(() => _selectedType = value!),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _showMultiSelectDialog(context, setStateInDialog),
                      child: const Text("Select Tags"),
                    ),
                    if (_selectedTags.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        children: _selectedTags.map((tag) => Chip(label: Text(tag))).toList(),
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
                  onPressed: () {
                    _addOrUpdateMedia(isEditing, doc?.id);
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? "Update" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiSelectDialog(BuildContext context, StateSetter setStateInParentDialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Tags'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _tags.map((tag) {
                return StatefulBuilder(
                  builder: (context, setStateInChildDialog) {
                    final isSelected = _selectedTags.contains(tag);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(tag),
                      onChanged: (bool? value) {
                        setStateInChildDialog(() {
                          if (value == true) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                        setStateInParentDialog(() {}); // Update parent dialog
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdateMedia(bool isEditing, String? docId) async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) return;

    final data = {
      'title': _titleController.text,
      'url': _urlController.text,
      'type': _selectedType,
      'tags': _selectedTags,
      'createdAt': isEditing ? null : FieldValue.serverTimestamp(),
      'active': true,
    };

    if (isEditing) {
      await _videos.doc(docId).update(data);
    } else {
      await _videos.add(data);
    }
  }

  void _deleteVideo(String docId) async {
    await _videos.doc(docId).delete();
  }

  void _toggleActive(DocumentSnapshot doc) async {
    bool currentStatus = doc['active'] ?? false;
    await _videos.doc(doc.id).update({'active': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Multimedia Guidance'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showMediaDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _videos.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isActive = data['active'] ?? false;
                      final tags = List<String>.from(data['tags'] ?? []);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: () => _showMediaDialog(doc: docs[index]),
                          title: Text(data['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('URL: ${data['url'] ?? ''}'),
                              Text('Type: ${data['type'] ?? ''}'),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4.0,
                                children: tags.map((tag) => Chip(label: Text(tag))).toList(),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(isActive ? Icons.visibility : Icons.visibility_off, color: isActive ? Colors.green : Colors.grey),
                                onPressed: () => _toggleActive(docs[index]),
                                tooltip: isActive ? 'Deactivate' : 'Activate',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVideo(docs[index].id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}