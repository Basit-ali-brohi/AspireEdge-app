//
//
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/testimonial.dart';
//
// class TestimonialController extends GetxController {
// final _db = FirebaseFirestore.instance;
// final testimonials = <Testimonial>[].obs;
// final loading = false.obs;
//
// @override
// void onInit() {
// super.onInit();
// // ✅ Stream all testimonials (admin can filter later in UI)
// _db
//     .collection('testimonials')
//     .orderBy('createdAt', descending: true)
//     .snapshots()
//     .listen((snap) {
// testimonials.value = snap.docs.map((d) => Testimonial.fromDoc(d)).toList();
// });
// }
//
// Future<void> submitTestimonial({
// required String userId,
// required String name,
// required String tier,
// required String imageUrl,
// required String story,
// String status = 'pending', // ✅ default if not passed
// }) async {
// loading.value = true;
// final doc = {
// 'userId': userId,
// 'name': name,
// 'tier': tier,
// 'imageUrl': imageUrl,
// 'story': story,
// 'status': status,
// 'createdAt': FieldValue.serverTimestamp(),
// };
// await _db.collection('testimonials').add(doc);
// loading.value = false;
// Get.snackbar(
// 'Submitted',
// status == 'published'
// ? 'Testimonial published successfully'
//     : 'Your testimonial is pending approval',
// );
// }
//
// Future<void> updateTestimonial(String id, Map<String, dynamic> data) async {
// await _db.collection('testimonials').doc(id).update(data);
// }
//
// Future<void> deleteTestimonial(String id) async {
// await _db.collection('testimonials').doc(id).delete();
// }
//
// // ✅ Status shortcuts
// Future<void> approve(String id) async {
// await updateTestimonial(id, {'status': 'published'});
// }
//
// Future<void> reject(String id) async {
// await updateTestimonial(id, {'status': 'rejected'});
// }
//
// Future<void> unpublish(String id) async {
// await updateTestimonial(id, {'status': 'hidden'});
// }
// }
//
//
// *testimonial form screeen*
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import '../../controllers/auth_user_controller.dart';
// import '../../controllers/testimonial_controller.dart';
// import '../../models/testimonial.dart';
// import '../../widgets/input_field.dart';
// import '../../widgets/primary_button.dart';
// import '../../core/app_routes.dart';
//
// class TestimonialFormScreen extends StatefulWidget {
// const TestimonialFormScreen({super.key});
//
// @override
// State<TestimonialFormScreen> createState() => _TestimonialFormScreenState();
// }
//
// class _TestimonialFormScreenState extends State<TestimonialFormScreen> {
// final _name = TextEditingController();
// final _imageUrl = TextEditingController();
// final _story = TextEditingController();
// final _tier = ''.obs;
// final _formKey = GlobalKey<FormState>();
//
// final auth = Get.find<AuthUserController>();
// final tc = Get.find<TestimonialController>();
//
// Testimonial? editing; // ✅ null => create
//
// @override
// void initState() {
// super.initState();
// final user = auth.currentUser.value;
// editing = Get.arguments as Testimonial?;
//
// if (editing != null) {
// // ✅ Prefill for edit
// _name.text = editing!.name;
// _imageUrl.text = editing!.imageUrl;
// _story.text = editing!.story;
// _tier.value = ["student", "graduate", "professional"]
//     .contains(editing!.tier)
// ? editing!.tier
//     : "student"; // ✅ fix invalid tier
// } else if (user != null) {
// // ✅ Prefill for new submission
// _name.text = user.role == 'admin' ? '' : user.name;
// _tier.value = ["student", "graduate", "professional"]
//     .contains(user.tier)
// ? user.tier
//     : "student";
// }
// }
//
// @override
// Widget build(BuildContext context) {
// final user = auth.currentUser.value;
// final bool isAdmin = user?.role == 'admin';
//
// return Scaffold(
// appBar: AppBar(
// title: Text(editing != null ? 'Edit Testimonial' : 'Share Your Testimonial'),
// ),
// body: Padding(
// padding: EdgeInsets.all(5.w),
// child: Form(
// key: _formKey,
// child: SingleChildScrollView(
// child: Column(children: [
// // Name
// InputField(
// controller: _name,
// label: 'Name',
// readOnly: !isAdmin && editing == null, // users can’t change name
// validator: (v) =>
// v == null || v.trim().isEmpty ? 'Name required' : null,
// ),
// SizedBox(height: 2.h),
//
// // Tier dropdown (only admin)
// if (isAdmin)
// Obx(() => DropdownButtonFormField<String>(
// value: _tier.value.isEmpty ? null : _tier.value,
// decoration: InputDecoration(
// labelText: "Select Tier",
// border: OutlineInputBorder(
// borderRadius: BorderRadius.circular(12),
// ),
// ),
// items: const [
// DropdownMenuItem(
// value: 'student', child: Text("Student")),
// DropdownMenuItem(
// value: 'graduate', child: Text("Graduate")),
// DropdownMenuItem(
// value: 'professional',
// child: Text("Professional")),
// ],
// onChanged: (v) => _tier.value = v ?? 'student',
// validator: (v) =>
// v == null || v.isEmpty ? "Tier required" : null,
// )),
// if (isAdmin) SizedBox(height: 2.h),
//
// // Image URL
// InputField(
// controller: _imageUrl,
// label: 'Image URL',
// keyboardType: TextInputType.url,
// ),
// SizedBox(height: 2.h),
//
// // Story
// TextFormField(
// controller: _story,
// maxLines: 6,
// decoration: InputDecoration(
// labelText: 'Your Story',
// labelStyle: TextStyle(fontSize: 12.sp),
// border: OutlineInputBorder(
// borderRadius: BorderRadius.circular(12),
// ),
// ),
// validator: (v) =>
// v == null || v.trim().isEmpty ? 'Story required' : null,
// ),
// SizedBox(height: 3.h),
//
// Obx(() => PrimaryButton(
// loading: tc.loading.value,
// onPressed: () async {
// if (!_formKey.currentState!.validate()) return;
//
// final userId = user?.id ?? '';
// final tier =
// isAdmin ? _tier.value : (user?.tier ?? 'student');
// final status =
// isAdmin ? 'published' : 'pending'; // ✅ fix
//
// if (editing != null) {
// // ✅ Update
// await tc.updateTestimonial(editing!.id, {
// 'name': _name.text.trim(),
// 'tier': tier,
// 'imageUrl': _imageUrl.text.trim(),
// 'story': _story.text.trim(),
// });
// Get.offAllNamed(AppRoutes.testimonialsList);
// } else {
// // ✅ Create
// await tc.submitTestimonial(
// userId: userId,
// name: _name.text.trim(),
// tier: tier,
// imageUrl: _imageUrl.text.trim().isEmpty
// ? 'https://via.placeholder.com/150'
//     : _imageUrl.text.trim(),
// story: _story.text.trim(),
// status: status,
// );
// Get.offAllNamed(AppRoutes.testimonialsList);
// }
// },
// label: editing != null ? 'Save Changes' : 'Submit Testimonial',
// )),
// ]),
// ),
// ),
// ),
// );
// }
// }
//
//
// *testimonial list screen*
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import '../../controllers/auth_user_controller.dart';
// import '../../controllers/testimonial_controller.dart';
// import '../../core/app_routes.dart';
// import '../../models/testimonial.dart';
// import '../../widgets/confirm_dialog.dart';
// import '../../widgets/entity_list_tile.dart';
//
// class TestimonialsListScreen extends StatelessWidget {
// const TestimonialsListScreen({super.key});
//
// @override
// Widget build(BuildContext context) {
// final tc = Get.put(TestimonialController());
// final auth = Get.find<AuthUserController>();
//
// // ✅ Check if this is "My Testimonials" screen
// final args = Get.arguments;
// final bool myStories = args is Map && args['myStories'] == true;
//
// return Scaffold(
// appBar: AppBar(
// title: Obx(() {
// final user = auth.currentUser.value;
// final isAdmin = (user?.role == 'admin');
// return Text(
// myStories
// ? 'My Testimonials'
//     : isAdmin
// ? 'Manage Testimonials'
//     : 'Success Stories',
// style: TextStyle(fontSize: 13.sp),
// );
// }),
// ),
// body: Obx(() {
// final user = auth.currentUser.value;
// final bool isAdmin = (user?.role == 'admin');
// final uid = user?.id;
//
// // ✅ Filter testimonials
// List<Testimonial> testimonials = tc.testimonials.where((t) {
// if (isAdmin) return true; // admin sees all
// if (myStories) return t.userId == uid; // user’s own stories
// return t.status == 'published' && t.tier == user?.tier; // published only
// }).toList();
//
// if (testimonials.isEmpty) {
// return Center(
// child: Text(
// myStories
// ? "You haven't added any testimonials yet."
//     : isAdmin
// ? 'No testimonials yet.'
//     : 'No stories available for ${user?.tier ?? 'users'}',
// style: TextStyle(fontSize: 11.sp),
// ),
// );
// }
//
// return ListView.builder(
// padding: EdgeInsets.all(3.w),
// itemCount: testimonials.length,
// itemBuilder: (_, i) {
// final Testimonial t = testimonials[i];
//
// return GestureDetector(
// onTap: () => Get.toNamed(AppRoutes.testimonialDetail, arguments: t),
// child: EntityListTile(
// title: t.name,
// subtitle: t.story,
// leadingUrl: t.imageUrl,
// isPublished: t.status == 'published',
//
// // ✅ Status badge only for "My Testimonials"
// trailing: myStories
// ? Text(
// t.status == 'published'
// ? "✅ Published"
//     : t.status == 'pending'
// ? "⌛ Pending"
//     : "❌ Hidden",
// style: TextStyle(
// fontSize: 10.sp,
// color: t.status == 'published'
// ? Colors.green
//     : t.status == 'pending'
// ? Colors.orange
//     : Colors.red,
// ),
// )
//     : null,
//
// // ✅ Admin-only options
// onEdit: isAdmin
// ? () => Get.toNamed(
// AppRoutes.testimonialForm,
// arguments: t,
// )
//     : null,
// onDelete: isAdmin
// ? () async {
// final confirm = await showDialog<bool>(
// context: context,
// builder: (_) => ConfirmDialog(
// title: 'Delete Testimonial',
// message: 'Delete story from ${t.name}?',
// ),
// );
// if (confirm == true) tc.deleteTestimonial(t.id);
// }
//     : null,
// onTogglePublish: isAdmin
// ? () {
// final newStatus = t.status == 'published'
// ? 'hidden'
//     : 'published';
// tc.updateTestimonial(t.id, {'status': newStatus});
// }
//     : null,
// ),
// );
// },
// );
// }),
// floatingActionButton: Obx(() {
// final user = auth.currentUser.value;
// final bool isAdmin = (user?.role == 'admin');
//
// // ✅ Admin can add directly
// // ✅ User can add from "My Testimonials"
// if (isAdmin || myStories) {
// return FloatingActionButton(
// onPressed: () => Get.toNamed(AppRoutes.testimonialForm),
// child: Icon(isAdmin ? Icons.add : Icons.edit),
// );
// }
// return const SizedBox.shrink();
// }),
// );
// }
// }