import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/testimonial_model.dart';

class TestimonialCarousel extends StatelessWidget {
  const TestimonialCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('testimonials')
          .where('approved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Testimonials load nahi ho paaye."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Abhi koi testimonials nahi hain. Jald hi add kiye jaayenge!",
              textAlign: TextAlign.center,
            ),
          );
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
            height: 250,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
        );
      },
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final TestimonialModel testimonial;

  const TestimonialCard({
    super.key,
    required this.testimonial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: testimonial.imageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(testimonial.imageUrl)
                      : null,
                  child: testimonial.imageUrl.isEmpty
                      ? Text(
                    testimonial.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Colors.blueGrey),
                  )
                      : null,
                ),
                const SizedBox(width: 10),
                // Name and Tier
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        testimonial.tier,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Testimonial story
            Expanded(
              child: Text(
                testimonial.story,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}