import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CadGenerationScreen extends HookConsumerWidget {
  const CadGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = useState<File?>(null);
    final isProcessing = useState(false);
    final processingProgress = useState(0.0);

    Future<void> _pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    }

    Future<void> _processImage() async {
      if (selectedImage.value == null) return;

      isProcessing.value = true;
      processingProgress.value = 0.0;

      // Simulate processing with incremental progress updates
      for (var i = 0; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        processingProgress.value = i / 100;
      }

      isProcessing.value = false;
      // Here you would navigate to the quote screen with the processed CAD file
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CAD Generation'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create CAD File from Image',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Take a photo or select an image of the part you want to fabricate. Our system will generate a CAD file and provide a quote.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: selectedImage.value == null
                    ? _buildImagePlaceholder()
                    : _buildSelectedImage(selectedImage.value!),
              ),
              const SizedBox(height: 16),
              if (isProcessing.value)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: processingProgress.value,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Processing image: ${(processingProgress.value * 100).toInt()}%',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: isProcessing.value
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isProcessing.value
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isProcessing.value || selectedImage.value == null
                    ? null
                    : _processImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Generate CAD File & Quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text('No image selected'),
            const SizedBox(height: 8),
            const Text(
              'Take a photo or select from gallery',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage(File image) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
} 