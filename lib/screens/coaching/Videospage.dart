import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = [
      {
        'title': 'How to Crack Interviews',
        'description': 'Tips and tricks to ace your interviews',
        'url': 'https://youtu.be/O3m14PVOq_g?si=LY8fMQnlyoUtg6AC',
      },
      {
        'title': 'Resume Building Tips',
        'description': 'Make a standout resume',
        'url': 'https://youtu.be/O3m14PVOq_g?si=LY8fMQnlyoUtg6AC',
      },
      {
        'title': 'Body Language Skills',
        'description': 'Improve your posture and confidence',
        'url': 'https://youtu.be/O3m14PVOq_g?si=LY8fMQnlyoUtg6AC',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Videos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(
                Icons.play_circle_fill,
                color: AppColors.primary,
                size: 40,
              ),
              title: Text(
                video['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(video['description']!),
              onTap: () async {
                final url = Uri.parse(video['url']!);

                try {
                  // Open in YouTube app or browser
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw 'Could not launch URL';
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error opening video: $e')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
