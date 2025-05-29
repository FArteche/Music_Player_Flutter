import 'package:flutter/material.dart';
import 'package:player_musica/model/Musica_Model.dart';
import 'package:player_musica/service/Musica_Service.dart';
import 'package:player_musica/widget/Card_Musica.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:player_musica/service/audio_player_handler.dart';

// Variável global para acessar o AudioHandler
late AudioPlayerHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado

  // Inicializa o just_audio_background com as configurações de notificação
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true, // Notificação persistente
    androidNotificationIcon: 'mipmap/ic_launcher', // Exemplo: use o ícone do seu app
    // androidStopForegroundOnPause: false, // Opcional: mantém a notificação mesmo em pausa
    // androidNotificationColor: Colors.purple.value, // Opcional: cor da notificação
  );

  // Inicializa o AudioService e obtém a instância do AudioHandler
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(), 
    config: const AudioServiceConfig(
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MusicaModel> musicas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarMusicas();
  }

  void carregarMusicas() async {
    try {
      musicas = await MusicaService.fetchMusicas();
    } catch (e) {
      print('Erro ao carregar músicas: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    // Não é necessário chamar dispose no _audioHandler aqui.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return Scaffold(
        appBar: AppBar(title: Text('Carregando Músicas...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Mudei de ValueListenableBuilder para StreamBuilder aqui
      body: StreamBuilder<MediaItem?>( // <--- ALTERADO AQUI
        stream: _audioHandler.mediaItem, // <--- Agora é um Stream<MediaItem?>
        builder: (context, mediaItemSnapshot) { // <--- Snapshot para o MediaItem
          final mediaItem = mediaItemSnapshot.data; // <--- Obtenha os dados do snapshot

          return StreamBuilder<PlaybackState>(
            stream: _audioHandler.playbackState,
            builder: (context, playbackStateSnapshot) { // <--- Snapshot para o PlaybackState
              final isPlaying = playbackStateSnapshot.data?.playing ?? false;
              final currentMediaId = mediaItem?.id; // Usando o mediaItem do snapshot exterior

              return ListView.builder(
                itemCount: musicas.length,
                itemBuilder: (context, index) {
                  final musica = musicas[index];
                  final isSelected = musica.url == currentMediaId;

                  return CardMusica(
                    musica: musica,
                    isPlaying: isSelected && isPlaying,
                    isSelected: isSelected,
                    onPressed: () {
                      if (isSelected) {
                        if (isPlaying) {
                          _audioHandler.pause();
                        } else {
                          _audioHandler.play();
                        }
                      } else {
                        _audioHandler.setMediaItemAndPlay(musica);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}