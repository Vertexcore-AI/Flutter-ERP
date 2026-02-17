import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class GlassImagePickerField extends StatefulWidget {
  final File? initialImage;
  final String? initialImageUrl;
  final Function(File?) onImageSelected;
  final String hintText;

  const GlassImagePickerField({
    super.key,
    this.initialImage,
    this.initialImageUrl,
    required this.onImageSelected,
    this.hintText = 'Select farm image',
  });

  @override
  State<GlassImagePickerField> createState() => _GlassImagePickerFieldState();
}

class _GlassImagePickerFieldState extends State<GlassImagePickerField> {
  File? _selectedImage;
  Uint8List? _webImageBytes; // For web platform
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      // Simple file picker configuration that works on all platforms
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;

        setState(() {
          _fileName = pickedFile.name;
        });

        if (kIsWeb) {
          // Web platform - use bytes
          if (pickedFile.bytes != null) {
            setState(() {
              _webImageBytes = pickedFile.bytes;
            });
            // For web, we'll create a temporary File object with a fake path
            // The actual upload will use bytes
            widget.onImageSelected(File(pickedFile.name));
          } else {
            throw Exception('No file data available');
          }
        } else {
          // Mobile/Desktop platform - use file path
          if (pickedFile.path != null && pickedFile.path!.isNotEmpty) {
            final file = File(pickedFile.path!);
            setState(() => _selectedImage = file);
            widget.onImageSelected(file);
          } else {
            throw Exception('No valid file path');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      debugPrint('Image picker error: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _webImageBytes = null;
      _fileName = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = _selectedImage != null ||
                     _webImageBytes != null ||
                     widget.initialImageUrl != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[200]!,
        ),
      ),
      child: hasImage
          ? _buildImagePreview(isDark)
          : _buildPickerButton(isDark),
    );
  }

  Widget _buildPickerButton(bool isDark) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: isDark ? Colors.white54 : Colors.grey[400],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.hintText,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: _buildImageWidget(),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _buildIconButton(
                icon: Icons.edit,
                onPressed: _pickImage,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.delete,
                onPressed: _removeImage,
                isDark: isDark,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _webImageBytes != null) {
      // Web: Display from bytes
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    } else if (_selectedImage != null) {
      // Mobile/Desktop: Display from file
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (widget.initialImageUrl != null) {
      // Network image fallback
      return Image.network(widget.initialImageUrl!, fit: BoxFit.cover);
    } else {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image)),
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: color ?? Colors.white,
      ),
    );
  }
}
