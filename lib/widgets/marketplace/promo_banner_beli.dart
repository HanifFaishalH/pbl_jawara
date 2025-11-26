import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  final Color color;

  const PromoBanner({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.storefront, size: 130, color: Colors.white.withOpacity(0.1)),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Selamat Datang di",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)
                ),
                SizedBox(height: 4),
                Text(
                  "Marketplace Jawara",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}