import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/neon_button.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() => _selectedFile = result.files.single.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Upload')),
      body: GradientBackground(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 62),
              const SizedBox(height: 12),
              Text(_selectedFile ?? 'No file selected'),
              const SizedBox(height: 14),
              NeonButton(label: 'Choose File', onPressed: _pickFile),
              const SizedBox(height: 10),
              NeonButton(
                label: 'Send File',
                onPressed: _selectedFile == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('File sent: $_selectedFile')),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
