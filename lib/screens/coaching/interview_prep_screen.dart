import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class InterviewPrepPage extends StatefulWidget {
  const InterviewPrepPage({Key? key}) : super(key: key);

  @override
  State<InterviewPrepPage> createState() => _InterviewPrepPageState();
}

class _InterviewPrepPageState extends State<InterviewPrepPage> {
  // YouTube controllers
  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;
  late YoutubePlayerController _controller3;

  // FAQ data
  final List<Map<String, String>> faqs = [
    {
      "question": "Tell me about yourself.",
      "answer":
      "Keep it short (2–3 minutes), highlight your education, key skills, and relevant experiences. End with why you’re excited about the role."
    },
    {
      "question": "Why do you want to work here?",
      "answer":
      "Research the company. Mention their values, products, or culture and connect it with your career goals."
    },
    {
      "question": "What are your strengths?",
      "answer":
      "Pick 2–3 strengths relevant to the job and give examples of how you’ve used them in past experiences."
    },
    {
      "question": "What is your biggest weakness?",
      "answer":
      "Choose a genuine weakness but show how you’re improving it. Never pick a weakness that’s a core skill for the job."
    },
    {
      "question": "Where do you see yourself in 5 years?",
      "answer":
      "Show ambition and commitment. Say you want to grow with the company and take on more responsibility."
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller1 = YoutubePlayerController(
      initialVideoId: 'cl9-_xVQ800',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    _controller2 = YoutubePlayerController(
      initialVideoId: 'wexzvClUcUk',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    _controller3 = YoutubePlayerController(
      initialVideoId: 'ZdjJdoEwCY4',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  // Build video card
  Widget _buildVideoCard(
      String title, String subtitle, YoutubePlayerController controller) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                aspectRatio: 16 / 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build FAQ Section
  Widget _buildFAQSection() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Text(
              "Common Interview Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...faqs.map((faq) => ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              title: Text(faq["question"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(faq["answer"]!, style: const TextStyle(color: Colors.black87)),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // Build Body Language Tips Section
  Widget _buildBodyLanguageSection() {
    final List<String> bodyTips = [
      "Maintain eye contact (but don’t stare).",
      "Sit up straight with confident posture.",
      "Use natural hand gestures while speaking.",
      "Smile genuinely when appropriate.",
      "Avoid fidgeting or crossing arms.",
      "Nod slightly to show active listening.",
    ];

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Body Language Tips",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...bodyTips.map(
                  (tip) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(tip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interview Preparation"),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              _buildBodyLanguageSection(),
              _buildVideoCard("Mock Interview", "Pre-Recorded Interview for Preparation.", _controller1),
              _buildVideoCard("Interview Tip #1", "How to Introduce Yourself.", _controller2),
              _buildVideoCard("Interview Tip #2", "3 Tips to crush your interview.", _controller3),
              _buildFAQSection(),
            ],
          ),
        ),
      ),
    );
  }
}
