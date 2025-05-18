import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/app_header.dart';

class AudioArchive extends StatefulWidget {
  const AudioArchive({super.key});

  @override
  State<AudioArchive> createState() => _AudioArchiveState();
}

class _AudioArchiveState extends State<AudioArchive> {
  final _player = AudioPlayer();
  final _scrollController = ScrollController();
  String? _currentUrl;
  String _searchQuery = '';
  bool _showHeader = true;
  double _lastScrollOffset = 0;

  static const _gql = r'''
    query SoloAudioMedia {
      assets(
        kind: "audio"
        orderBy: "filename ASC"
      ) {
        url
        filename
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    // Reset UI when the track finishes
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      if (s.processingState == ProcessingState.completed) {
        setState(() => _currentUrl = null);
        _player.stop();
      }
      // Always refresh state so play/pause icon stays in sync
      if (mounted) setState(() {});
    });

    // Configure controller to manage the collapsing header
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.positions.isEmpty) return;

    final currentScroll = _scrollController.offset;

    // Detect scroll direction with a small threshold for sensitivity
    if (currentScroll - _lastScrollOffset > 5 && currentScroll > 40) {
      // Scrolling down: hide header
      if (_showHeader) {
        setState(() => _showHeader = false);
      }
    } else if (_lastScrollOffset - currentScroll > 5) {
      // Scrolling up: show header
      if (!_showHeader) {
        setState(() => _showHeader = true);
      }
    }

    _lastScrollOffset = currentScroll;
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _play(String url) async {
    await _player.stop();
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    await _player.play();
    setState(() => _currentUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb, 'Questa versione di AudioArchive è pensata soltanto per il Web');

    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Collapsible header (logo + search bar)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _showHeader ? 150 : 0,
            // Clip to avoid overflow when collapsing
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: _showHeader
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Offstage(
              offstage: !_showHeader,
              child: Column(
                children: [
                  // Logo / title
                  SizedBox(
                    height: 80,
                    child: Center(
                      child: Image.asset(
                        'assets/bianchiii-logo.png',
                        height: 60,
                      ),
                    ),
                  ),
// Search bar
                  Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      constraints: const BoxConstraints(maxWidth: 600), // Limite massimo di larghezza
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.deepPurpleAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Cerca file audio...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: Colors.deepPurpleAccent),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Audio list
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(_gql)),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  return Center(child: Text('Errore: ${result.exception}'));
                }

                final allAssets = result.data!['assets'] as List<dynamic>;

                // Search filter
                final filteredAssets = _searchQuery.isEmpty
                    ? allAssets
                    : allAssets
                    .where((asset) => (asset['filename'] as String)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredAssets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessun risultato trovato',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredAssets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final asset = filteredAssets[i];
                    final url = asset['url'] as String;
                    final filename = asset['filename'] as String;
                    final isCurrent = _currentUrl == url;

                    return Card(
                      elevation: 2,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isCurrent
                            ? BorderSide(
                          color: Colors.deepPurpleAccent,
                          width: 2,
                        )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          filename,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.audiotrack_rounded,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        trailing: StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
                          builder: (_, snap) {
                            final playing = snap.data?.playing ?? false;
                            final isCurrentTrack = _currentUrl == url;

                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCurrentTrack && playing
                                    ? Colors.deepPurpleAccent
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isCurrentTrack && playing ? Icons.pause : Icons.play_arrow,
                                  color: isCurrentTrack && playing
                                      ? theme.colorScheme.onPrimary
                                      : Colors.deepPurpleAccent,
                                ),
                                onPressed: () async {
                                  if (!isCurrentTrack) {
                                    setState(() => _currentUrl = url);
                                    await _player.stop();
                                    await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
                                    await _player.play();
                                    return;
                                  }

                                  if (playing) {
                                    await _player.pause();
                                  } else {
                                    await _player.play();
                                  }
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
