import 'package:flutter/material.dart';

class StreamSelector extends StatefulWidget {
  const StreamSelector({Key? key}) : super(key: key);

  @override
  State<StreamSelector> createState() => _StreamSelectorState();
}

class _StreamSelectorState extends State<StreamSelector>
    with SingleTickerProviderStateMixin {
  // Interests
  final List<String> interests = [
    'Math', 'Coding', 'Physics', 'Chemistry', 'Biology', 'Design', 'Writing',
    'Business', 'Social Studies', 'Art', 'Economics', 'Music', 'Sports',
    'Engineering', 'Medicine', 'Law', 'Psychology', 'Philosophy', 'Languages',
    'Astronomy', 'Robotics', 'AI & ML', 'Finance', 'Marketing',
    'Political Science', 'History', 'Geography', 'Environmental Science',
    'Culinary', 'Theater', 'Film'
  ];

  // Strengths
  final List<String> strengths = [
    'Problem Solving', 'Creativity', 'Analytical', 'Communication', 'Teamwork',
    'Leadership', 'Attention to Detail', 'Critical Thinking', 'Adaptability',
    'Organization', 'Empathy', 'Time Management', 'Research', 'Negotiation',
    'Decision Making', 'Strategic Planning'
  ];

  // Streams with tags
  final List<StreamProfile> streams = [
    StreamProfile(
        name: 'Computer Science',
        description: 'Coding, software development, AI, and algorithms.',
        tags: ['Math', 'Coding', 'AI & ML', 'Problem Solving', 'Analytical'],
        icon: Icons.computer),
    StreamProfile(
        name: 'Engineering',
        description: 'Design and build systems, machines, and structures.',
        tags: ['Math', 'Physics', 'Engineering', 'Problem Solving'],
        icon: Icons.engineering),
    StreamProfile(
        name: 'Medicine / Healthcare',
        description: 'Biology, patient care, and healthcare sciences.',
        tags: ['Biology', 'Chemistry', 'Medicine', 'Empathy'],
        icon: Icons.healing),
    StreamProfile(
        name: 'Business / Finance',
        description: 'Entrepreneurship, finance, marketing, and management.',
        tags: ['Business', 'Finance', 'Marketing', 'Leadership'],
        icon: Icons.business_center),
    StreamProfile(
        name: 'Design / Arts',
        description: 'Visual design, UX/UI, creative arts and multimedia.',
        tags: ['Design', 'Creativity', 'Art', 'Communication'],
        icon: Icons.palette),
    StreamProfile(
        name: 'Humanities / Social Sciences',
        description: 'History, psychology, sociology, languages, writing.',
        tags: ['Writing', 'Social Studies', 'Critical Thinking'],
        icon: Icons.menu_book),
    StreamProfile(
        name: 'Natural Sciences',
        description: 'Physics, chemistry, research, and lab sciences.',
        tags: ['Physics', 'Chemistry', 'Research'],
        icon: Icons.science),
    StreamProfile(
        name: 'Law',
        description: 'Legal studies, jurisprudence, and advocacy.',
        tags: ['Law', 'Communication', 'Critical Thinking'],
        icon: Icons.gavel),
    StreamProfile(
        name: 'Culinary Arts',
        description: 'Cooking, gastronomy, and food sciences.',
        tags: ['Culinary', 'Creativity', 'Time Management'],
        icon: Icons.restaurant),
    StreamProfile(
        name: 'Music / Performing Arts',
        description: 'Music, theater, and performance.',
        tags: ['Music', 'Art', 'Creativity', 'Teamwork'],
        icon: Icons.music_note),
    StreamProfile(
        name: 'Astronomy / Space Sciences',
        description: 'Space research, astrophysics, and cosmology.',
        tags: ['Astronomy', 'Physics', 'Math', 'Research'],
        icon: Icons.travel_explore),
    StreamProfile(
        name: 'Political Science / Governance',
        description: 'Politics, governance, international relations.',
        tags: ['Political Science', 'Leadership', 'Critical Thinking'],
        icon: Icons.how_to_vote),
    StreamProfile(
        name: 'Robotics / AI',
        description: 'AI, robotics, automation, and technology development.',
        tags: ['Robotics', 'Coding', 'AI & ML', 'Problem Solving'],
        icon: Icons.smart_toy),
  ];

  final Set<String> selectedInterests = {};
  final Set<String> selectedStrengths = {};
  List<ScoredStream> recommendations = [];

  void _toggleInterest(String interest) {
    setState(() {
      selectedInterests.contains(interest)
          ? selectedInterests.remove(interest)
          : selectedInterests.add(interest);
    });
  }

  void _toggleStrength(String strength) {
    setState(() {
      selectedStrengths.contains(strength)
          ? selectedStrengths.remove(strength)
          : selectedStrengths.add(strength);
    });
  }

  void _recommend() {
    List<ScoredStream> scored = [];
    for (var s in streams) {
      double score = 0;
      for (var t in s.tags) {
        if (selectedInterests.contains(t)) score += 1.0;
        if (selectedStrengths.contains(t)) score += 1.5;
      }
      scored.add(ScoredStream(stream: s, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      recommendations = scored;
    });
  }

  void _clearSelections() {
    setState(() {
      selectedInterests.clear();
      selectedStrengths.clear();
      recommendations = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F9D58), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.school, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text("Stream Selector",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                        onPressed: _clearSelections,
                        icon: const Icon(Icons.refresh, color: Colors.white))
                  ],
                ),
              ),
              // Card Body
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Interests",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: interests
                              .map((i) => FilterChip(
                            label: Text(i),
                            selected: selectedInterests.contains(i),
                            onSelected: (_) => _toggleInterest(i),
                          ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Select Strengths",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: strengths
                              .map((s) => ChoiceChip(
                            label: Text(s),
                            selected: selectedStrengths.contains(s),
                            onSelected: (_) => _toggleStrength(s),
                          ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: _recommend,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Recommend Streams"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: recommendations.isEmpty
                            ? const Center(
                          child: Text("No recommendations yet."),
                        )
                            : ListView.builder(
                            itemCount: recommendations.length,
                            itemBuilder: (context, index) {
                              final item = recommendations[index];
                              return Card(
                                child: ListTile(
                                  leading: Icon(item.stream.icon,
                                      color: Colors.green),
                                  title: Text(item.stream.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(item.stream.description),
                                  trailing: Text(
                                      item.score.toStringAsFixed(1)),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StreamProfile {
  final String name;
  final String description;
  final List<String> tags;
  final IconData icon;

  StreamProfile(
      {required this.name,
        required this.description,
        required this.tags,
        required this.icon});
}

class ScoredStream {
  final StreamProfile stream;
  final double score;

  ScoredStream({required this.stream, required this.score});
}
