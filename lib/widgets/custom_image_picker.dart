// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// /// Widget CustomImagePicker
// /// - Menampilkan tombol untuk memilih gambar dari gallery atau kamera.
// /// - Menampilkan preview setelah gambar dipilih.
// /// - Memanggil [onImageSelected] dengan File gambar.
// class CustomImagePicker extends StatefulWidget {
//   final ValueChanged<File> onImageSelected;
//   final String buttonText;
//   final double previewHeight;

//   const CustomImagePicker({
//     Key? key,
//     required this.onImageSelected,
//     this.buttonText = 'Pilih Gambar',
//     this.previewHeight = 150,
//   }) : super(key: key);

//   @override
//   _CustomImagePickerState createState() => _CustomImagePickerState();
// }

// class _CustomImagePickerState extends State<CustomImagePicker> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? picked = await _picker.pickImage(source: source);
//     if (picked != null) {
//       final file = File(picked.path);
//       setState(() => _selectedImage = file);
//       widget.onImageSelected(file);
//     }
//   }

//   void _showPickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text('Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text('Camera'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ElevatedButton.icon(
//           icon: Icon(Icons.image),
//           label: Text(widget.buttonText),
//           onPressed: _showPickerOptions,
//         ),
//         if (_selectedImage != null) ...[
//           SizedBox(height: 8),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               _selectedImage!,
//               height: widget.previewHeight,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// lib/widgets/custom_image_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// CustomImagePicker
///
/// Widget untuk memilih gambar dari Gallery atau Camera,
/// menampilkan modal pilihan, lalu preview file yang dipilih.
/// Memanggil callback [onImageSelected] dengan File hasil pick.
class CustomImagePicker extends StatefulWidget {
  /// Callback ketika user memilih image
  final ValueChanged<File> onImageSelected;

  /// Teks pada tombol
  final String buttonText;

  /// Tinggi preview gambar
  final double previewHeight;

  const CustomImagePicker({
    super.key,
    required this.onImageSelected,
    this.buttonText = 'Pilih Gambar',
    this.previewHeight = 150,
  });

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text(widget.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4D5BFF),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onPressed: _showPickerOptions,
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              height: widget.previewHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
