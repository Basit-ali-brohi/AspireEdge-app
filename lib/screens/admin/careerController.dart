// career_controller.dart
import 'package:get/get.dart';
import '../../models/career_model.dart';
import '../../services/career_service.dart';


class CareerController extends GetxController {
  final CareerService _careerService = CareerService();

  // Reactive variables
  var careers = <CareerModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedIndustry = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCareers();
  }

  // Load careers from Firestore
  void loadCareers() {
    isLoading.value = true;
    _careerService.streamCareers().listen((careerList) {
      careers.value = careerList;
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load careers: $error');
    });
  }

  // Add career
  Future<void> addCareer(CareerModel career) async {
    try {
      isLoading.value = true;
      await _careerService.createCareer(career);
      isLoading.value = false;
      Get.snackbar('Success', 'Career added successfully');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add career: $e');
    }
  }

  // Update career
  Future<void> updateCareer(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _careerService.updateCareer(id, data);
      isLoading.value = false;
      Get.snackbar('Success', 'Career updated successfully');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to update career: $e');
    }
  }

  // Delete career
  Future<void> deleteCareer(String id) async {
    try {
      isLoading.value = true;
      await _careerService.deleteCareer(id);
      isLoading.value = false;
      Get.snackbar('Deleted', 'Career removed successfully');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to delete career: $e');
    }
  }

  // Filtered list based on search and industry
  List<CareerModel> get filteredCareers {
    return careers.where((career) {
      final matchesSearch = career.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          career.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesIndustry =
          selectedIndustry.value == 'All' || career.industry == selectedIndustry.value;
      return matchesSearch && matchesIndustry;
    }).toList();
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Set selected industry
  void setSelectedIndustry(String industry) {
    selectedIndustry.value = industry;
  }
}
