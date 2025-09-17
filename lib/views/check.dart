// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class UploadImageScreen extends StatefulWidget {
//   const UploadImageScreen({super.key});

//   @override
//   State<UploadImageScreen> createState() => _UploadImageScreenState();
// }

// class _UploadImageScreenState extends State<UploadImageScreen> {
//   File? _imageFile;
//   final _picker = ImagePicker();
//   bool _isUploading = false;
//   String? _downloadUrl;

//   // Method to pick an image from the gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   // Method to upload the image to Firebase Storage
//   Future<void> _uploadImage() async {
//     if (_imageFile == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       // Create a unique file name
//       // final String fileName = path.basename(_imageFile!.path);
//       // Create a reference to the storage location
//       final storageRef = FirebaseStorage.instance.ref().child(
//         'images/${_imageFile!.path.split('/').last}',
//       );

//       // Upload the file
//       final uploadTask = storageRef.putFile(_imageFile!);

//       // Wait for the upload to complete
//       final snapshot = await uploadTask.whenComplete(() {});

//       // Get the download URL
//       final url = await snapshot.ref.getDownloadURL();
//       setState(() {
//         _downloadUrl = url;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Image uploaded successfully!')),
//       );
//     } on FirebaseException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Upload failed: ${e.message}')));
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Image to Firebase')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Display selected image or a placeholder
//               if (_imageFile != null)
//                 Expanded(child: Image.file(_imageFile!))
//               else
//                 const Text('No image selected.'),

//               const SizedBox(height: 20),

//               // Button to pick image
//               ElevatedButton.icon(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text('Pick Image'),
//               ),
//               const SizedBox(height: 20),

//               // Button to upload image
//               if (_isUploading)
//                 const CircularProgressIndicator()
//               else
//                 ElevatedButton.icon(
//                   onPressed: _imageFile != null ? _uploadImage : null,
//                   icon: const Icon(Icons.cloud_upload),
//                   label: const Text('Upload to Firebase'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _imageFile != null
//                         ? Colors.blue
//                         : Colors.grey,
//                   ),
//                 ),
//               const SizedBox(height: 20),

//               // Display the uploaded image from its URL
//               if (_downloadUrl != null)
//                 Expanded(child: Image.network(_downloadUrl!)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
