import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class ImageArchive extends StatelessWidget {
  const ImageArchive({super.key});

  static const List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1518779578993-ec3579fee39f',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
    'https://images.unsplash.com/photo-1495560778119-ff83415a74be',
    'https://images.unsplash.com/photo-1481349518771-20055b2a7b24',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e',
    'https://images.unsplash.com/photo-1432958576631-279bf4740dbf',
    'https://images.unsplash.com/photo-1437992353603-3a8c36ef9d62',
    'https://images.unsplash.com/photo-1443890923422-7819ed4101c0',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archivio Immagini')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _ImageViewer(initialIndex: index)),
            ),
            child: Hero(
              tag: 'image_$index',
              child: CachedNetworkImage(imageUrl: _imageUrls[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.initialIndex});
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => __ImageViewerState();
}

class __ImageViewerState extends State<_ImageViewer> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: ImageArchive._imageUrls.length,
            itemBuilder: (context, index) {
              final url = ImageArchive._imageUrls[index];
              return Hero(
                tag: 'image_$index',
                child: PhotoView(imageProvider: CachedNetworkImageProvider(url)),
              );
            },
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