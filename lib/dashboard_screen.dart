import 'package:bianchiii/screens/audio_archive.dart';
import 'package:bianchiii/screens/image_archive.dart';
import 'package:bianchiii/screens/video_archive.dart';
import 'package:bianchiii/widgets/app_header.dart';
import 'package:bianchiii/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:bianchiii/screens/audio_archive.dart';
import 'package:bianchiii/screens/image_archive.dart';
import 'package:bianchiii/screens/video_archive.dart';
import 'package:bianchiii/widgets/app_header.dart';
import 'package:bianchiii/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Usa direttamente le liste già definite dalle varie classi
  static const List<String> _previewImages = [
    'assets/photos/img-1.jpg',
    'assets/photos/img-2.jpg',
    'assets/photos/img-3.jpg',
  ];

  static const List<String> _previewVideos = [
    'assets/video/video-1.mp4',
    'assets/video/video-2.mp4',
  ];

  // Query per contare gli elementi audio
  static const String _countAudioQuery = r'''
    query CountAudio {
      assets(kind: "audio") {
        id
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMedium = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sezione Audio (con conteggio dinamico da GraphQL)
                Query(
                  options: QueryOptions(document: gql(_countAudioQuery)),
                  builder: (result, {fetchMore, refetch}) {
                    int audioCount = 0;
                    if (!result.isLoading && !result.hasException && result.data != null) {
                      audioCount = (result.data!['assets'] as List<dynamic>).length;
                    }

                    return _MediaSection(
                      title: 'Audio',
                      icon: Icons.graphic_eq_rounded,
                      color: Colors.deepPurpleAccent,
                      isWide: isWide,
                      isMedium: isMedium,
                      previewContent: _AudioPreview(),
                      count: audioCount,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AudioArchive()),
                      ),
                    );
                  },
                ),

                // Sezione Immagini (conteggio esatto dalle risorse)
                _MediaSection(
                  title: 'Immagini',
                  icon: Icons.photo_library_outlined,
                  color: Colors.blueAccent,
                  isWide: isWide,
                  isMedium: isMedium,
                  previewContent: _ImagesPreview(images: _previewImages),
                  count: ImageArchive.assetCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImageArchive()),
                  ),
                ),

                // Sezione Video (conteggio esatto dalle risorse)
                _MediaSection(
                  title: 'Video',
                  icon: Icons.play_circle_outline,
                  color: Colors.greenAccent,
                  isWide: isWide,
                  isMedium: isMedium,
                  previewContent: _VideosPreview(videos: _previewVideos),
                  count: VideoArchive.assetCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoArchive()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isWide,
    required this.isMedium,
    required this.previewContent,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;
  final bool isMedium;
  final Widget previewContent;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? _buildWideLayout(context)
                : _buildNarrowLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Testo e statistiche
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 36),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$count elementi disponibili',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.arrow_forward, color: color),
                  label: Text('Esplora $title'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Anteprima
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              child: previewContent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icona e titolo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Anteprima
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: isMedium ? 200 : 160,
            width: double.infinity,
            child: previewContent,
          ),
        ),

        const SizedBox(height: 16),

        // Pulsante
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.arrow_forward, color: color),
            label: Text('Esplora $title'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurpleAccent.withOpacity(0.7),
            Colors.deepPurpleAccent.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.audio_file,
              size: 64,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 16),
            _buildWaveform(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        20,
            (index) {
          // Crea un pattern di onde audio simulato
          final height = 10.0 + (index % 3) * 10.0 + (index % 7) * 5.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImagesPreview extends StatelessWidget {
  const _ImagesPreview({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
      ),
      child: Row(
        children: images.map((imagePath) =>
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            )
        ).toList(),
      ),
    );
  }
}

class _VideosPreview extends StatefulWidget {
  const _VideosPreview({required this.videos});
  final List<String> videos;

  @override
  State<_VideosPreview> createState() => _VideosPreviewState();
}

class _VideosPreviewState extends State<_VideosPreview> {
  final Map<String, VideoPlayerController> _controllers = {};
  final Set<String> _initialized = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    for (final video in widget.videos) {
      final controller = VideoPlayerController.asset(video);
      _controllers[video] = controller;

      controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized.add(video);
            // Imposta il video in pausa con un frame visibile
            controller.setVolume(0);
            controller.seekTo(const Duration(milliseconds: 500));
            controller.pause();
          });
        }
      }).catchError((error) {
        print('Errore caricamento anteprima video: $video - $error');
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.7),
            Colors.greenAccent.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < widget.videos.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Aumentato il padding
                child: ClipRRect( // Aggiunto ClipRRect per arrotondare i bordi
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Frame del video o fallback
                      _initialized.contains(widget.videos[i])
                          ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controllers[widget.videos[i]]!.value.size.width,
                          height: _controllers[widget.videos[i]]!.value.size.height,
                          child: VideoPlayer(_controllers[widget.videos[i]]!),
                        ),
                      )
                          : Container(color: Colors.black38),

                      // Overlay scuro
                      Container(color: Colors.black.withOpacity(0.2)),

                      // Icona play
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),

                      // Etichetta video
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Video ${i + 1}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}