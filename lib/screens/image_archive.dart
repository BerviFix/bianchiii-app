import 'package:flutter/material.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:photo_view/photo_view.dart';
  import 'package:graphql_flutter/graphql_flutter.dart';

  class ImageArchive extends StatelessWidget {
    const ImageArchive({super.key});

    static const _gql = r'''
      query ImagesMedia {
        assets(
          kind: "image"
          orderBy: "filename ASC"
        ) {
          url
          filename
        }
      }
    ''';

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Archivio Immagini')),
        body: Query(
          options: QueryOptions(document: gql(_gql)),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (result.hasException) {
              return Center(child: Text('Errore: ${result.exception}'));
            }

            final assets = result.data!['assets'] as List<dynamic>;

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                final url = asset['url'] as String;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _ImageViewer(
                      assets: assets,
                      initialIndex: index
                    )),
                  ),
                  child: Hero(
                    tag: 'image_$index',
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  class _ImageViewer extends StatefulWidget {
    const _ImageViewer({required this.assets, required this.initialIndex});
    final List<dynamic> assets;
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
              itemCount: widget.assets.length,
              itemBuilder: (context, index) {
                final asset = widget.assets[index];
                final url = asset['url'] as String;

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