import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/testimonial_model.dart';

class TestimonialManagementScreen extends StatefulWidget {
  final bool isAdmin;

  const TestimonialManagementScreen({super.key, this.isAdmin = false});

  @override
  State<TestimonialManagementScreen> createState() =>
      _TestimonialManagementScreenState();
}

class _TestimonialManagementScreenState
    extends State<TestimonialManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tierController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // ---------------- Add Testimonial ----------------
  Future<void> _addTestimonial() async {
    if (_nameController.text.isEmpty || _storyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Story are required")),
      );
      return;
    }

    try {
      final docRef = _firestore.collection('testimonials').doc();
      final newTestimonial = TestimonialModel(
        testimonialId: docRef.id,
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        tier: _tierController.text.trim(),
        story: _storyController.text.trim(),
        company: _companyController.text.trim(),
        currentPosition: _positionController.text.trim(),
        location: _locationController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        approved: false, // pending approval
      );

      await docRef.set(newTestimonial.toMap());

      _nameController.clear();
      _imageUrlController.clear();
      _tierController.clear();
      _storyController.clear();
      _companyController.clear();
      _positionController.clear();
      _locationController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Testimonial submitted for approval")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ---------------- Delete ----------------
  Future<void> _deleteTestimonial(String id) async {
    await _firestore.collection('testimonials').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Testimonial deleted")),
    );
  }

  // ---------------- Approve ----------------
  Future<void> _approveTestimonial(String id) async {
    await _firestore.collection('testimonials').doc(id).update({
      'approved': true,
      'updatedAt': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Testimonial approved")),
    );
  }

  // ---------------- Add Dialog ----------------
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Testimonial"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: "Image URL")),
              TextField(controller: _tierController, decoration: const InputDecoration(labelText: "Tier / Category")),
              TextField(controller: _storyController, decoration: const InputDecoration(labelText: "Story")),
              TextField(controller: _positionController, decoration: const InputDecoration(labelText: "Current Position")),
              TextField(controller: _companyController, decoration: const InputDecoration(labelText: "Company")),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: "Location")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { _addTestimonial(); Navigator.pop(context); }, child: const Text("Submit")),
        ],
      ),
    );
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? "Admin - Manage Testimonials" : "Testimonials"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      floatingActionButton: widget.isAdmin
          ? null
          : FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Admin sees all, user sees only approved
        stream: widget.isAdmin
            ? _firestore.collection('testimonials')
            .orderBy('createdAt', descending: true)
            .snapshots()
            : _firestore.collection('testimonials')
            .where('approved', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No testimonials found"));

          final docs = snapshot.data!.docs;

          // Convert Timestamp -> DateTime safely
          final testimonials = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['createdAt'] is Timestamp) data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
            if (data['updatedAt'] is Timestamp) data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
            return TestimonialModel.fromMap(data);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: testimonial.imageUrl.isNotEmpty ? NetworkImage(testimonial.imageUrl) : null,
                    child: testimonial.imageUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(testimonial.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (testimonial.tier.isNotEmpty) Text(testimonial.tier, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(testimonial.shortStory),
                      if (widget.isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            testimonial.approved ? "Approved ✅" : "Pending ⏳",
                            style: TextStyle(color: testimonial.approved ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  trailing: widget.isAdmin
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!testimonial.approved)
                        IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _approveTestimonial(testimonial.testimonialId)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTestimonial(testimonial.testimonialId)),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
