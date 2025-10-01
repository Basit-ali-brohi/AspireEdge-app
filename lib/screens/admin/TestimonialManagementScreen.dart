import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ✅ Added for timestamp formatting
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class TestimonialManagementScreen extends StatefulWidget {
  const TestimonialManagementScreen({super.key});

  @override
  State<TestimonialManagementScreen> createState() =>
      _TestimonialManagementScreenState();
}

class _TestimonialManagementScreenState
    extends State<TestimonialManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tierController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  int _rating = 5;

  // ---------------- Add / Update ----------------
  Future<void> _addOrUpdateTestimonial({String? id}) async {
    if (_nameController.text.isEmpty || _storyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name and Story are required"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final testimonialId =
        id ?? _firestore.collection('testimonials').doc().id;

    final data = {
      'name': _nameController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'tier': _tierController.text.trim().isEmpty
          ? 'Student'
          : _tierController.text.trim(),
      'story': _storyController.text.trim(),
      'rating': _rating,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'testimonialId': testimonialId,
      'isActive': true,
      'company': '',
      'location': '',
      'currentPosition': '',
      'displayOrder': 0,
      'tags': null,
    };

    try {
      if (id == null) {
        await _firestore
            .collection('testimonials')
            .doc(testimonialId)
            .set(data);
      } else {
        await _firestore.collection('testimonials').doc(id).update(data);
      }

      _clearForm();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Testimonial saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving testimonial: $e")),
      );
    }
  }

  // ---------------- Delete ----------------
  Future<void> _deleteTestimonial(String id) async {
    try {
      await _firestore.collection('testimonials').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Testimonial deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting testimonial: $e")),
      );
    }
  }

  // ---------------- Show Form ----------------
  void _showForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      // Safely cast
      _nameController.text = doc.get('name')?.toString() ?? '';
      _imageUrlController.text = doc.get('imageUrl')?.toString() ?? '';
      _tierController.text = doc.get('tier')?.toString() ?? 'Student';
      _storyController.text = doc.get('story')?.toString() ?? '';
      _rating = (doc.get('rating') ?? 5) as int;
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? "Add Testimonial" : "Edit Testimonial"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              TextField(
                controller: _tierController,
                decoration: const InputDecoration(
                    labelText: "Tier (Student/Graduate/Professional)"),
              ),
              TextField(
                controller: _storyController,
                decoration: const InputDecoration(labelText: "Story"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Rating: "),
                  Expanded(
                    child: Slider(
                      value: _rating.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (val) {
                        setState(() {
                          _rating = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _addOrUpdateTestimonial(id: doc?.id),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _imageUrlController.clear();
    _tierController.clear();
    _storyController.clear();
    _rating = 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Testimonials"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('testimonials')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading testimonials"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No testimonials available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              final name = doc.get('name')?.toString() ?? 'Unknown';
              final story = doc.get('story')?.toString() ?? '';
              final imageUrl = doc.get('imageUrl')?.toString() ?? '';
              final createdAt = (doc.get('createdAt') as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child:
                    imageUrl.isEmpty ? Text(name[0].toUpperCase()) : null,
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(story),
                      const SizedBox(height: 4),
                      Text(
                        'Created At: ${DateFormat('yyyy-MM-dd – kk:mm').format(createdAt)}',
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () => _showForm(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _deleteTestimonial(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
