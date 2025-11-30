import 'package:flutter/material.dart';

class DetailContent extends StatelessWidget {
  final String title;
  final String category;
  final String location;
  final String date;
  final String description;

  const DetailContent({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3))
          ),
          child: Text(
            category.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold, fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Judul
        Text(
          title,
          style: const TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800,
            color: Colors.black87, height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        // Info Row
        Row(
          children: [
            _buildInfoIcon(Icons.calendar_today, date),
            const SizedBox(width: 24),
            _buildInfoIcon(Icons.location_on, location),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        // Deskripsi
        const Text(
          "Deskripsi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}