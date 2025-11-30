import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailHeader extends StatelessWidget {
  final String? fotoPath;

  const DetailHeader({super.key, this.fotoPath});

  @override
  Widget build(BuildContext context) {
    // Setup URL Proxy
    const String baseImageUrl = "http://localhost:8000/api/image-proxy/";
    
    String finalUrl = "";
    if (fotoPath != null && fotoPath!.isNotEmpty) {
      finalUrl = fotoPath!.startsWith('http') 
          ? fotoPath! 
          : "$baseImageUrl${fotoPath!.startsWith('/') ? fotoPath!.substring(1) : fotoPath!}";
    }

    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            finalUrl.isEmpty
              ? Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50, color: Colors.grey))
              : Image.network(
                  finalUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }
}