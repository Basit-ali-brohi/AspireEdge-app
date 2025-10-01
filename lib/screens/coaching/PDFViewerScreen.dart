import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';

// For Web download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PDFViewerScreen extends StatefulWidget {
  final String assetPath;
  const PDFViewerScreen({super.key, required this.assetPath});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPdfFromAssets();
  }

  Future<void> loadPdfFromAssets() async {
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final file = File('${(await getTemporaryDirectory()).path}/temp.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      setState(() {
        localPath = file.path;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load PDF")),
        );
      }
    }
  }

  Future<void> downloadPdf() async {
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final data = byteData.buffer.asUint8List();
      final fileName = widget.assetPath.split('/').last;

      if (kIsWeb) {
        final blob = html.Blob([data], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return;
      }

      bool granted = await Permission.storage.request().isGranted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final downloadsPath = Platform.isAndroid
          ? Directory('${dir.path.split("Android")[0]}Download')
          : dir;

      if (!downloadsPath.existsSync()) {
        downloadsPath.createSync(recursive: true);
      }

      final file = File('${downloadsPath.path}/$fileName');
      await file.writeAsBytes(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF downloaded to ${file.path}")),
        );
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View CV"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadPdf,
          ),
        ],
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
