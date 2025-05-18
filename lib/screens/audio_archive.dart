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
  String? _currentUrl;

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
    // reset UI quando finisce il brano
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      if (s.processingState == ProcessingState.completed) {
        setState(() => _currentUrl = null);
        _player.stop();
      } else {
        setState(() {}); // aggiorna icona play/pause
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String url) async {
    // ferma sempre l'audio corrente, anche se diverso
    await _player.stop();
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    await _player.play();
    setState(() => _currentUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb,
    'Questa versione di AudioArchive è pensata soltanto per il Web');

    return Scaffold(
      appBar: AppHeader(),
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final asset = assets[i];
              final url = asset['url'] as String;
              final filename = asset['filename'] as String;
              final playingThis = _currentUrl == url && _player.playing;

              return Card(
                child: ListTile(
                  title: Text(filename),
                  trailing: StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      final isCurrent = _currentUrl == url;

                      return IconButton(
                        icon: Icon(isCurrent && playing ? Icons.pause : Icons.play_arrow),
                        onPressed: () async {
                          // ▶ se è un altro file
                          if (!isCurrent) {
                            setState(() => _currentUrl = url);
                            await _player.stop();
                            await _player.setAudioSource(
                              AudioSource.uri(Uri.parse(url)),
                            );
                            await _player.play();
                            return;
                          }

                          // ⏸ / ▶ riprendi sullo stesso file
                          if (playing) {
                            await _player.pause();
                            setState(() {});
                          } else {
                            await _player.play();
                            setState(() {});
                          }
                        },
                      );
                    },
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
