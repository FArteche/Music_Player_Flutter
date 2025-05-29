import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player_musica/model/Musica_Model.dart'; // Importe seu modelo de música

// Extende a classe BasicAudioHandler que já implementa muitos métodos padrão
class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      // Atualiza o estado de reprodução para a notificação
      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop, // Adiciona o controle de stop
        ],
        processingState: _getAudioServiceProcessingState(processingState),
        playing: isPlaying,
      ));
    });

    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource != null) {
        // Atualiza a mídia atual para a notificação
        mediaItem.add(sequenceState!.currentSource!.tag as MediaItem);
      }
    });
  }

  // Mapeia o estado de processamento do just_audio para audio_service
  AudioProcessingState _getAudioServiceProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle; // Fallback
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.dispose(); // Importante: dispose do player aqui quando o serviço para
    // Reseta o estado da mídia quando para
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    mediaItem.add(null); // Limpa a mídia atual
    // Chame super.stop() para notificar o audio_service que a tarefa terminou
    return super.stop();
  }

  // Método para carregar e tocar uma nova música
  Future<void> setMediaItemAndPlay(MusicaModel musica) async {
    final newMediaItem = MediaItem(
      id: musica.url, // ID único, pode ser a URL
      album: "Player de Música", // Pode ser o nome do seu app ou um álbum padrão
      title: musica.title,
      artist: musica.author,
      artUri: Uri.parse("https://upload.wikimedia.org/wikipedia/commons/c/c1/LP_Vinyl_Symbol_Icon.png"), // Imagem da notificação
      duration: Duration(seconds: musica.duration.toInt()),
    );

    // Define a mídia no player
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(musica.url), tag: newMediaItem),
    );

    // Adiciona a mídia ao estado do audio_service
    mediaItem.add(newMediaItem);
    await play(); // Toca a música
  }
}