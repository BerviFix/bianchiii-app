import 'package:bianchiii/screens/audio_archive.dart';
import 'package:bianchiii/screens/image_archive.dart';
import 'package:bianchiii/screens/video_archive.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _Category(
        label: 'Audio',
        icon: Icons.graphic_eq_rounded,
        color: Colors.deepPurpleAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AudioArchive()),
        ),
      ),
      _Category(
        label: 'Immagini',
        icon: Icons.photo_library_outlined,
        color: Colors.blueAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ImageArchive()),
        ),
      ),
      _Category(
        label: 'Video',
        icon: Icons.play_circle_outline,
        color: Colors.greenAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoArchive()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Image.asset(
            'assets/bianchiii-logo.png',
            height: 50,
          ),
        ),
        centerTitle: true, // Opzionale: centra il logo
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: isWide ? 3 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isWide ? 1.4 : 3.6,
            children: categories.map((c) => _DashboardCard(category: c)).toList(),
          );
        },
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Category({required this.label, required this.icon, required this.color, required this.onTap});
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({super.key, required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: category.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [category.color.withOpacity(0.7), category.color.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 64),
                  const SizedBox(height: 12),
                  Text(category.label, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}