import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player_musica/model/Musica_Model.dart';

class MusicaPlayerService {
  final AudioPlayer _player = AudioPlayer();

  MusicaModel? musicaAtual;

  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  Future<void> tocarOuPausar(MusicaModel musica) async {
    // Se já é a mesma música:
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

    // Se for nova música, para a anterior e toca a nova
    await _player.stop();
    musicaAtual = musica;

    try {
      await _player.setUrl(musica.url);
      await _player.play();
      isPlaying.value = true;

      _player.playerStateStream.listen((state) {
        isBuffering.value = state.processingState == ProcessingState.buffering;
        isPlaying.value = state.playing;
      });
    } catch (e) {
      print("Erro ao tocar música: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
