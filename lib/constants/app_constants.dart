class AppConstants {
  // App Info
  static const String appName = 'AspireEdge';
  static const String appTagline = 'Career Passport - Future Path Explorer';
  static const String appVersion = '1.0.0';
  
  // User Tiers
  static const String studentTier = 'Student';
  static const String graduateTier = 'Graduate';
  static const String professionalTier = 'Professional';
  static const String adminTier = 'Admin';
  
  // Career Industries
  static const List<String> industries = [
    'Information Technology',
    'Healthcare',
    'Design',
    'Agriculture',
    'Finance',
    'Education',
    'Engineering',
    'Marketing',
    'Media',
    'Law',
    'Science',
    'Arts',
    'Sports',
    'Hospitality',
    'Real Estate',
    'Manufacturing',
    'Transportation',
    'Energy',
    'Government',
    'Non-Profit'
  ];
  
  // Quiz Categories
  static const List<String> quizCategories = [
    'Interests',
    'Skills',
    'Personality',
    'Values',
    'Goals',
    'Learning Style'
  ];
  
  // Resource Types
  static const List<String> resourceTypes = [
    'Blog',
    'EBook',
    'Video',
    'Podcast',
    'Template',
    'Guide',
    'Webinar',
    'Course'
  ];
  
  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.aspireedge.com';
  
  // Storage Paths
  static const String userImagesPath = 'user_images';
  static const String careerImagesPath = 'career_images';
  static const String resourceFilesPath = 'resource_files';
  static const String testimonialImagesPath = 'testimonial_images';
  
  // Database Collections
  static const String usersCollection = 'users';
  static const String careersCollection = 'careers';
  static const String quizzesCollection = 'quizzes';
  static const String testimonialsCollection = 'testimonials';
  static const String feedbackCollection = 'feedback';
  static const String resourcesCollection = 'resources';
  static const String bookmarksCollection = 'bookmarks';
  static const String wishlistCollection = 'wishlist';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
}
