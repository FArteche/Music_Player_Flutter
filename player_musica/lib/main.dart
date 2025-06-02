import 'package:flutter/material.dart';
import 'package:player_musica/model/Musica_Model.dart';
import 'package:player_musica/service/Musica_Player_Service.dart';
import 'package:player_musica/service/Musica_Service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:player_musica/widget/Card_Musica.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.farteche.channel.audio',
    androidNotificationChannelName: 'Reprodução de Áudio',
    androidNotificationOngoing: true,
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  final playerService = MusicaPlayerService();
  List<MusicaModel> musicas = [];
  bool carregando = true;
  bool isPlaying = false;

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
    playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) return const Center(child: CircularProgressIndicator());

    return ValueListenableBuilder<bool>(
      valueListenable: playerService.isPlaying,
      builder: (context, isPlaying, _) {
        return ListView.builder(
          itemCount: musicas.length,
          itemBuilder: (context, index) {
            final musica = musicas[index];
            final isSelected =
                playerService.musicaAtual?.url == musica.url;

            return CardMusica(
              musicaC: musica,
              isPlaying: isPlaying,
              isSelected: isSelected,
              onPressed: () => playerService.tocarOuPausar(musica),
            );
          },
        );
      },
    );
  }
}
