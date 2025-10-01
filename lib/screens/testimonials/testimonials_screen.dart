import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/testimonial_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Aapka existing code yahan aayega, jaise ki Welcome Card aur Quick Actions)
          const SizedBox(height: 24),
          Text(
            'Success Stories',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Testimonial Carousel
          SizedBox(
            height: 260,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('testimonials')
                  .where('approved', isEqualTo: true) // ✅ Sirf approved testimonials
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Abhi koi success stories nahi hain."));
                }

                final testimonials = snapshot.data!.docs
                    .map((doc) => TestimonialModel.fromDocument(doc))
                    .toList();

                return CarouselSlider.builder(
                  itemCount: testimonials.length,
                  itemBuilder: (context, index, realIndex) {
                    final testimonial = testimonials[index];
                    return TestimonialCard(testimonial: testimonial);
                  },
                  options: CarouselOptions(
                    height: 260,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    viewportFraction: 0.85,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final TestimonialModel testimonial;

  const TestimonialCard({super.key, required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: testimonial.imageUrl != null && testimonial.imageUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(testimonial.imageUrl!)
                  : null,
              child: testimonial.imageUrl == null || testimonial.imageUrl!.isEmpty
                  ? Text(
                testimonial.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: AppColors.primary),
              )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              testimonial.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (testimonial.tier.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  testimonial.tier,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              testimonial.story,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}