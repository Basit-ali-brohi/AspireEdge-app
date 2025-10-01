# AspireEdge - Career Passport & Future Path Explorer

A comprehensive Flutter-based career guidance application that helps students, graduates, and professionals explore career paths, take assessments, and access coaching resources.

## 🚀 Features

### ✅ Completed Features

#### 1. **Authentication System**
- User registration and login with email/password
- Multi-tier user system (Student, Graduate, Professional, Admin)
- Secure password validation and error handling
- Firebase Authentication integration

#### 2. **Career Bank**
- Browse and filter careers by industry
- Detailed career information with salary ranges, skills, and education paths
- Search functionality across careers, skills, and industries
- Beautiful career cards with ratings and view counts
- Career detail screens with comprehensive information

#### 3. **Interactive Career Quiz**
- Multi-step career assessment with 5+ questions
- Score mapping across different categories (Interests, Skills, Personality, etc.)
- AI-powered career recommendations
- Detailed results with category breakdown
- Recommended career tier based on responses

#### 4. **Resources Hub**
- Multiple resource types: Blogs, E-Books, Videos, Podcasts, Templates
- Advanced filtering and search capabilities
- Resource categorization and tagging
- Download and bookmark functionality
- Detailed resource view with author information

#### 5. **Coaching Tools**
- **Stream Selector**: Academic stream guidance based on interests and skills
- **CV Tips & Templates**: Professional resume building resources
- **Interview Preparation**: Common questions, tips, and practice sessions
- **Body Language Guide**: Non-verbal communication tips

#### 6. **Modern UI/UX**
- Material Design 3 with custom color scheme
- Smooth animations and transitions
- Responsive design for all screen sizes
- Custom widgets and components
- Beautiful splash screen with animations

#### 7. **Data Models & Firebase Integration**
- Complete Firestore data models for all entities
- User management with profiles and preferences
- Career, Quiz, Resource, and Feedback models
- Firebase Authentication and Firestore ready

## 🏗️ Project Structure

```
lib/
├── constants/          # App constants, colors, and configurations
├── models/            # Data models for all entities
├── services/          # Firebase and API services
├── screens/           # All app screens
│   ├── auth/         # Authentication screens
│   ├── career/       # Career-related screens
│   ├── coaching/     # Coaching tools screens
│   ├── home/         # Main app screens
│   ├── quiz/         # Quiz and assessment screens
│   └── resources/    # Resources hub screens
├── widgets/           # Reusable UI components
└── utils/            # Utility functions
```

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **UI**: Material Design 3
- **Navigation**: Go Router
- **HTTP**: Dio
- **Local Storage**: SharedPreferences, SQLite
- **Media**: Cached Network Image, Image Picker
- **Maps**: Google Maps Flutter
- **Animations**: Lottie

## 📱 Screenshots

### Main Features
- **Splash Screen**: Animated welcome screen
- **Login/SignUp**: Beautiful authentication screens
- **Dashboard**: Quick actions and recent activity
- **Career Bank**: Browse and filter careers
- **Quiz**: Interactive career assessment
- **Resources**: Access learning materials
- **Coaching**: Career guidance tools
- **Profile**: User management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aspire_edge
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Enable Storage
5. Add configuration files to respective platforms

### Environment Variables
- No additional environment variables required
- All configurations are in `lib/constants/`

## 📊 Database Schema

### Collections
- **users**: User profiles and preferences
- **careers**: Career information and details
- **quizzes**: Quiz questions and scoring
- **resources**: Learning materials and content
- **testimonials**: Success stories
- **feedback**: User feedback and suggestions

## 🎯 Key Features in Detail

### Career Bank
- Industry-wise filtering (IT, Healthcare, Design, etc.)
- Detailed career cards with salary ranges
- Search across titles, skills, and industries
- Career recommendations based on quiz results

### Interactive Quiz
- 5+ assessment questions
- Real-time progress tracking
- Category-based scoring
- Personalized career recommendations
- Detailed results analysis

### Resources Hub
- Multiple content types
- Advanced filtering and search
- Bookmark and download functionality
- Author information and ratings
- Category-based organization

### Coaching Tools
- Stream selector with interest/skill matching
- CV templates and writing tips
- Interview preparation with common questions
- Body language guidance
- Career success tips

## ✅ **COMPLETE FEATURES**

### **All Major Features Implemented:**
- ✅ **Admin Panel**: Complete content management system
- ✅ **Multimedia Features**: Video embedding, podcasts, testimonials carousel
- ✅ **User Profile Management**: Advanced profile editing and management
- ✅ **Feedback System**: Complete feedback collection and management
- ✅ **Testimonials**: Success stories carousel with real user stories
- ✅ **Coaching Tools**: Stream selector, CV tips, interview preparation
- ✅ **Career Bank**: Complete career exploration with filtering
- ✅ **Quiz System**: Multi-step career assessment with AI recommendations
- ✅ **Resources Hub**: Blogs, ebooks, videos, podcasts with filtering
- ✅ **Authentication**: Complete user management with tier selection

## 🔮 Future Enhancements

### Optional Advanced Features
- **Push Notifications**: Real-time updates
- **Offline Support**: Enhanced cached content access
- **Social Features**: User interactions and sharing
- **Advanced Analytics**: Detailed user behavior tracking
- **AI Chatbot**: Career guidance assistant

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Developer**: AI Assistant
- **Project**: AspireEdge Career Guidance App
- **Version**: 1.0.0

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**AspireEdge** - Empowering career journeys through technology! 🚀