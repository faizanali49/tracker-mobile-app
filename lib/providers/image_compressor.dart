// // lib/providers/image_utils_provider.dart
// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:riverpod/riverpod.dart';
// import 'package:flutter/foundation.dart'; // For kIsWeb
// import 'package:flutter_image_compress/flutter_image_compress.dart';

// class ImageUtils {
//   Future<String?> compressAndConvertToBase64(File file) async {
//     try {
//       // Check platform correctly for Flutter
//       if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
//         // Mobile compression
//         final Uint8List? result = await FlutterImageCompress.compressWithFile(
//           file.absolute.path,
//           quality: 40,
//           minWidth: 300,
//           minHeight: 300,
//         );
//         if (result == null) {
//           print("Compression returned null");
//           return null;
//         }
//         return base64Encode(result);
//       } else {
//         // Web/Desktop fallback: just read bytes
//         print("Using fallback method (Web/Desktop)");
//         final bytes = await file.readAsBytes();
//         return base64Encode(bytes);
//       }
//     } catch (e) {
//       print("❌ Compression failed: $e");
//       // Final fallback: try reading original bytes
//       try {
//         final bytes = await file.readAsBytes();
//         return base64Encode(bytes);
//       } catch (e2) {
//         print("❌ Fallback also failed: $e2");
//         return null; // Indicate complete failure
//       }
//     }
//   }
// }

// // Create a Riverpod Provider for the ImageUtils class
// final imageUtilsProvider = Provider<ImageUtils>((ref) {
//   return ImageUtils();
// });
