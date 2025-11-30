import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KegiatanImagePicker extends StatelessWidget {
  final String? initialUrl;
  final XFile? newImageFile;
  final VoidCallback onPickImage;

  const KegiatanImagePicker({
    super.key,
    this.initialUrl,
    this.newImageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    // Setup URL Proxy
    const String baseProxyUrl = "http://localhost:8000/api/image-proxy/"; 
    
    String finalOldUrl = "";
    if (initialUrl != null && initialUrl!.isNotEmpty) {
      if (initialUrl!.startsWith('http')) {
        finalOldUrl = initialUrl!;
      } else {
        String cleanPath = initialUrl!.startsWith('/') ? initialUrl!.substring(1) : initialUrl!;
        finalOldUrl = "$baseProxyUrl$cleanPath";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dokumentasi / Banner", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: newImageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(newImageFile!.path, fit: BoxFit.cover)
                        : Image.file(File(newImageFile!.path), fit: BoxFit.cover),
                  )
                : (finalOldUrl.isNotEmpty) 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          finalOldUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text("Tap untuk upload foto", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
          ),
        ),
        if (newImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Foto baru terpilih (Belum disimpan)", 
              style: TextStyle(color: Colors.green[700], fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}