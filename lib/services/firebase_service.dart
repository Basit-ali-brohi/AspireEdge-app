import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Singleton instance
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  // Private constructor
  FirebaseService._();

  // ---------------- Firebase Initialization ----------------
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      print("✅ Firebase Initialized Successfully");
    } catch (e) {
      print("❌ Firebase Initialization Failed: $e");
      rethrow;
    }
  }

  // ---------------- Firebase Instances ----------------
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  // ---------------- Auth Helpers ----------------
  User? get currentUser => auth.currentUser;
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // ---------------- Firestore Collections ----------------
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get careersCollection => firestore.collection('careers');
  CollectionReference get quizzesCollection => firestore.collection('quizzes');
  CollectionReference get testimonialsCollection => firestore.collection('testimonials');
  CollectionReference get feedbackCollection => firestore.collection('feedback');
  CollectionReference get resourcesCollection => firestore.collection('resources');
  CollectionReference get bookmarksCollection => firestore.collection('bookmarks');
  CollectionReference get wishlistCollection => firestore.collection('wishlist');
  CollectionReference get quizResultsCollection => firestore.collection('quiz_results');

  // ---------------- Storage References ----------------
  Reference get storageRef => storage.ref();
  Reference get userImagesRef => storageRef.child('user_images');
  Reference get careerImagesRef => storageRef.child('career_images');
  Reference get resourceFilesRef => storageRef.child('resource_files');
  Reference get testimonialImagesRef => storageRef.child('testimonial_images');

  // ---------------- Helper Methods ----------------
  String generateId() => firestore.collection('temp').doc().id;
  Timestamp get currentTimestamp => Timestamp.now();
  WriteBatch get batch => firestore.batch();
  Future<T> runTransaction<T>(TransactionHandler<T> handler) => firestore.runTransaction(handler);

  // ---------------- Offline Persistence ----------------
  Future<void> enableOfflinePersistence() async {
    try {
      await firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      print("✅ Offline persistence enabled");
    } catch (e) {
      print("⚠️ Could not enable offline persistence: $e");
    }
  }

  // ---------------- Clear Cache ----------------
  Future<void> clearCache() async {
    try {
      await firestore.clearPersistence();
      print("🗑️ Firestore cache cleared");
    } catch (e) {
      print("⚠️ Could not clear cache: $e");
    }
  }

  // ---------------- Debugging ----------------
  void debugPrintCollections() {
    print('📂 Users: ${usersCollection.path}');
    print('📂 Careers: ${careersCollection.path}');
    print('📂 Quizzes: ${quizzesCollection.path}');
    print('📂 Resources: ${resourcesCollection.path}');
  }
}
