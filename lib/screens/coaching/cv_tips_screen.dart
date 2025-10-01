import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class TemplateItem {
  final String name;
  final String file;
  final String subtitle;

  TemplateItem({
    required this.name,
    required this.file,
    required this.subtitle,
  });
}

class CvTipsPage extends StatelessWidget {
  CvTipsPage({Key? key}) : super(key: key);

  final List<TemplateItem> templates = [
    TemplateItem(
      name: "Professional CV",
      file: "assets/tamplates/template1.pdf",
      subtitle: "Formal layout for corporate jobs",
    ),
    TemplateItem(
      name: "Creative CV",
      file: "assets/tamplates/template2.pdf",
      subtitle: "Stylish design for creative roles",
    ),
    TemplateItem(
      name: "Modern CV",
      file: "assets/tamplates/template3.pdf",
      subtitle: "Clean design for tech positions",
    ),
    TemplateItem(
      name: "Simple CV",
      file: "assets/tamplates/template4.pdf",
      subtitle: "Minimalist format for internships",
    ),
  ];

  // 🔹 Open Template
  Future<void> _openTemplate(BuildContext context, TemplateItem t) async {
    try {
      final bytes = await rootBundle.load(t.file);
      final data = bytes.buffer.asUint8List();

      // Mobile: save to temp and open
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/${t.file.split('/').last}");
      await file.writeAsBytes(data);
      await OpenFile.open(file.path);
    } catch (e) {
      _showSnack(context, "Open failed: $e");
    }
  }

  // 🔹 Download Template
  Future<void> _downloadTemplate(BuildContext context, TemplateItem t) async {
    try {
      final bytes = await rootBundle.load(t.file);
      final data = bytes.buffer.asUint8List();

      // Mobile
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnack(context, "Storage permission denied");
          return;
        }
      }

      final dir = await _getDownloadsDirectory();
      if (dir == null) {
        _showSnack(context, "Downloads folder not found");
        return;
      }

      final file = File("${dir.path}/${t.file.split('/').last}");
      await file.writeAsBytes(data);
      _showSnack(context, "Saved to ${file.path}");
    } catch (e) {
      _showSnack(context, "Download failed: $e");
    }
  }

  // Get platform-specific downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        return await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      } else {
        // Fallback desktop (optional)
        return await getTemporaryDirectory();
      }
    } catch (_) {
      return null;
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CV Tips",
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Offers resume formats, sample templates, and do's and don'ts.",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.description, color: Colors.white),
                    )
                  ],
                ),
              ),

              // Do's and Don'ts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Do's", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("- Keep it concise (1–2 pages)."),
                        Text("- Tailor your CV to the role."),
                        Text("- Use clear headings and bullet points."),
                        SizedBox(height: 12),
                        Text("Don'ts", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("- Don’t include unrelated personal details."),
                        Text("- Avoid long paragraphs."),
                        Text("- Don’t use tiny fonts or cramped layout."),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Templates List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: templates.length,
                  itemBuilder: (context, idx) {
                    final t = templates[idx];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.shade50,
                          ),
                          child: Center(
                            child: Icon(Icons.picture_as_pdf, size: 28, color: Colors.green.shade700),
                          ),
                        ),
                        title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(t.subtitle),
                        onTap: () => _openTemplate(context, t),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadTemplate(context, t),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
