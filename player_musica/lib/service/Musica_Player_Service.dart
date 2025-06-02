import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../model/Musica_Model.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MusicaPlayerService {
  // Singleton
  static final MusicaPlayerService _instancia = MusicaPlayerService._interno();
  factory MusicaPlayerService() => _instancia;
  MusicaPlayerService._interno();

  final AudioPlayer _player = AudioPlayer();

  MusicaModel? musicaAtual;
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  Future<void> tocarOuPausar(MusicaModel musica) async {
    if (musicaAtual?.url == musica.url) {
      if (_player.playing) {
        await _player.pause();
        isPlaying.value = false;
      } else {
        await _player.play();
        isPlaying.value = true;
      }
      return;
    }

    await _player.stop();
    musicaAtual = musica;

    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(musica.url),
          tag: MediaItem(
            id: musica.url,
            title: musica.title,
            artist: musica.author,
            duration: Duration(seconds: musica.duration.toInt()),
          ),
        ),
      );
      await _player.play();
      isPlaying.value = true;

      _player.playerStateStream.listen((state) {
        isBuffering.value = state.processingState == ProcessingState.buffering;
        isPlaying.value = state.playing;
      });
    } catch (e) {
      print('Erro ao tocar música: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
