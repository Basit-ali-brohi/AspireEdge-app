import 'package:aspire_edge/screens/profileScreen/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../MultimediaGuidanceScreen/MultimediaGuidanceScreen.dart';
import '../auth/login_screen.dart';
import '../career/career_bank_screen.dart';
import '../contacctScreen/ContactUsScreen.dart';
import '../feedback/feedback_screen.dart';
import '../quiz/quiz_screen.dart';
import '../resources/resources_screen.dart';
import '../coaching/coaching_screen.dart';
import '../testimonials/AddUserTestimonialScreen.dart';
import '../../models/testimonial_model.dart';

import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CareerBankScreen(),
    const QuizScreen(),
    const ResourcesScreen(),
    const CoachingScreen(),
    const MultimediaGuidanceScreen(), // ✅ Added this screen
  ];

  final List<String> _screenTitles = [
    'AspireEdge',
    'Careers',
    'Quiz',
    'Resources',
    'Coaching',
    'Multimedia ', //
  ];

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                const Icon(Icons.school, size: 28, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _screenTitles[_currentIndex],
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'AspireEdge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outlined),
            activeIcon: Icon(Icons.work),
            label: 'Careers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Coaching',
          ),
          BottomNavigationBarItem( // ✅ New item added here
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Multimedia',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.white.withOpacity(0.3),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Careers'),
            onTap: () => _navigateToScreen(1),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quiz'),
            onTap: () => _navigateToScreen(2),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Resources'),
            onTap: () => _navigateToScreen(3),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Coaching'),
            onTap: () => _navigateToScreen(4),
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Multimedia Guidance'),
            onTap: () => _navigateToScreen(5),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- DASHBOARD ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.displayName ?? 'User',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ready to explore your career path?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              double spacing = 16;
              double width =
                  (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                      crossAxisCount;
              double height = 160;
              double childAspectRatio = width / height;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildQuickActionCard(
                      context, 'Take Career Quiz', Icons.quiz, AppColors.secondary, () {}),
                  _buildQuickActionCard(
                      context, 'Explore Careers', Icons.work, AppColors.accent, () {}),
                  _buildQuickActionCard(
                      context, 'CV Builder', Icons.description, AppColors.success, () {}),
                  _buildQuickActionCard(
                      context, 'Resources', Icons.library_books, AppColors.info, () {}),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Testimonials Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Stories',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                tooltip: "Add Your Testimonial",
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddUserTestimonialScreen()));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('testimonials')
                  .where('approved', isEqualTo: true)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No testimonials yet"));
                }

                final testimonials = snapshot.data!.docs
                    .map((doc) => TestimonialModel.fromDocument(doc))
                    .toList();

                return PageView.builder(
                  controller: _pageController,
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = testimonials[index];
                    return _buildTestimonialCard(
                      testimonial.name,
                      testimonial.imageUrl,
                      testimonial.story,
                      testimonial.tier,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(icon, size: 30, color: color),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                flex: 2,
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
      String name, String imageUrl, String story, String tier) {
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
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/images/default_avatar.png')
              as ImageProvider,
            ),
            const SizedBox(height: 12),
            Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (tier.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  tier,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              story,
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