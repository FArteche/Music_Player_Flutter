

import 'package:flutter/material.dart';
import 'package:player_musica/model/Musica_Model.dart';

class CardMusica extends StatelessWidget {
  final MusicaModel musica;
  final VoidCallback onPressed;
  final bool isPlaying;
  final bool isSelected;

  const CardMusica({
    required this.musica,
    required this.onPressed,
    required this.isPlaying,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            "https://upload.wikimedia.org/wikipedia/commons/c/c1/LP_Vinyl_Symbol_Icon.png",
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Icon(Icons.music_note),
          ),
        ),
        title: Text(musica.title),
        subtitle: Text(musica.author),
        trailing: IconButton(
          icon: Icon(
            isSelected
                ? (isPlaying ? Icons.pause : Icons.play_arrow)
                : Icons.play_arrow,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
