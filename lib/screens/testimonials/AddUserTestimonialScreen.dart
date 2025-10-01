import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/testimonial_model.dart'; // Apni model class ko import karein

class AddUserTestimonialScreen extends StatefulWidget {
  const AddUserTestimonialScreen({super.key});

  @override
  State<AddUserTestimonialScreen> createState() =>
      _AddUserTestimonialScreenState();
}

class _AddUserTestimonialScreenState extends State<AddUserTestimonialScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  String _selectedTier = "Student";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitTestimonial() async {
    if (_nameController.text.isEmpty || _storyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Naam aur Kahani zaroori hai")),
      );
      return;
    }

    try {
      final docRef = _firestore.collection("testimonials").doc();
      final newTestimonial = TestimonialModel(
        testimonialId: docRef.id,
        name: _nameController.text.trim(),
        story: _storyController.text.trim(),
        tier: _selectedTier,
        approved: false, // ✅ Yahan fix kiya gaya hai
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: "",
      );

      await docRef.set(newTestimonial.toMap());

      _nameController.clear();
      _storyController.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Testimonial submit ho gaya, approval ka intezaar hai!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Testimonial"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTier,
              items: ["Student", "Graduate", "Professional"]
                  .map((tier) => DropdownMenuItem(value: tier, child: Text(tier)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTier = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Aapki Category"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Success Story"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTestimonial,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}