import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoArchive extends StatelessWidget {
  const VideoArchive({super.key});

  // Lista statica dei percorsi dei video in assets/video
  static const List<String> _assetVideos = [
    'assets/video/video-1.mp4',
    'assets/video/video-2.mp4',
    'assets/video/video-3.mp4',
    'assets/video/video-4.mp4',
    'assets/video/video-5.mp4',
    'assets/video/video-6.mp4',
    'assets/video/video-7.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archivio Video')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determina il numero di colonne in base alla larghezza
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              // Rapporto flessibile invece di un rapporto fisso
              childAspectRatio: constraints.maxWidth > 600 ? 16/9 : 1,
            ),
            itemCount: _assetVideos.length,
            itemBuilder: (context, index) => _VideoThumbnail(assetPath: _assetVideos[index]),
          );
        },
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({required this.assetPath});
  final String assetPath;

  @override
  State<_VideoThumbnail> createState() => __VideoThumbnailState();
}

class __VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            // Imposto il video in pausa con un frame visibile
            _controller.setVolume(0);
            _controller.play();
            _controller.pause();
          });
        }
      }).catchError((error) {
        print('Errore caricamento video: ${widget.assetPath} - $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _VideoPlayerScreen(assetPath: widget.assetPath)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _isInitialized
                ? Container(
              color: Colors.black,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox.fromSize(
                  size: Size(
                    _controller.value.size.width,
                    _controller.value.size.height,
                  ),
                  child: VideoPlayer(_controller),
                ),
              ),
            )
                : Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            // Overlay scuro semi-trasparente
            Container(color: Colors.black.withOpacity(0.2)),
            // Icona play
            const Center(
              child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  const _VideoPlayerScreen({required this.assetPath});
  final String assetPath;

  @override
  State<_VideoPlayerScreen> createState() => __VideoPlayerScreenState();
}

class __VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller.play();
          });
        }
      }).catchError((error) {
        print('Errore riproduzione video: ${widget.assetPath} - $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _isInitialized
                ? _VideoControls(controller: _controller)
                : const SizedBox(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  const _VideoControls({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_VideoControls> createState() => __VideoControlsState();
}

class __VideoControlsState extends State<_VideoControls> {
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _volume = widget.controller.value.volume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VideoProgressIndicator(widget.controller, allowScrubbing: true),
          ),
          Row(
            children: [
              // Parte sinistra con peso uguale
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: const SizedBox(width: 40),
                ),
              ),

              // Play/Pausa realmente al centro
              IconButton(
                icon: Icon(
                  widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.value.isPlaying
                        ? widget.controller.pause()
                        : widget.controller.play();
                  });
                },
              ),

              // Controllo volume a destra con stesso peso
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      _volume <= 0 ? Icons.volume_off
                          : _volume < 0.5 ? Icons.volume_down
                          : Icons.volume_up,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 120,
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            widget.controller.setVolume(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}