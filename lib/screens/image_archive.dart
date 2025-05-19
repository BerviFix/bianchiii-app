import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';

import '../widgets/app_header.dart';

class ImageArchive extends StatelessWidget {
  const ImageArchive({super.key});

  // Lista statica dei percorsi delle immagini in assets/photos
  static const List<String> _assetImages = [
    'assets/photos/img-1.jpg',
    'assets/photos/img-2.jpg',
    'assets/photos/img-3.jpg',
    'assets/photos/img-4.jpg',
    'assets/photos/img-5.jpg',
    'assets/photos/img-6.jpg',
    'assets/photos/img-7.jpg',
    'assets/photos/img-8.jpg',
    'assets/photos/img-9.jpg',
    'assets/photos/img-10.jpg',
    'assets/photos/img-11.jpg',
    'assets/photos/img-12.jpg',
    'assets/photos/img-13.jpg',
    'assets/photos/img-14.jpg',
    'assets/photos/img-15.jpg',
  ];

  static int get assetCount => _assetImages.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.black,
      appBar: AppHeader(),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _assetImages.length,
        itemBuilder: (context, index) {
          final assetPath = _assetImages[index];

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _ImageViewer(
                  assetPaths: _assetImages,
                  initialIndex: index
              )),
            ),
            child: Hero(
              tag: 'image_$index',
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Stampa l'errore specifico per debugging
                  print('Errore caricamento: $assetPath - $error');
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.white70)
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.assetPaths, required this.initialIndex});
  final List<String> assetPaths;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => __ImageViewerState();
}

class __ImageViewerState extends State<_ImageViewer> {
  late PageController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (_controller.page!.round() < widget.assetPaths.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_controller.page!.round() > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _nextImage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousImage();
            }
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.assetPaths.length,
              itemBuilder: (context, index) {
                final assetPath = widget.assetPaths[index];

                return Hero(
                  tag: 'image_$index',
                  child: PhotoView.customChild(
                    backgroundDecoration: const BoxDecoration(color: Colors.black),
                    child: Image.asset(
                      assetPath,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.white60),
                              SizedBox(height: 16),
                              Text('Immagine non disponibile',
                                  style: TextStyle(color: Colors.white70))
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // Pulsante precedente
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
                  onPressed: _previousImage,
                ),
              ),
            ),
            // Pulsante successivo
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                  onPressed: _nextImage,
                ),
              ),
            ),
            // Pulsante chiudi
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
      ),
    );
  }
}
