// Define a classe MusicaModel que representa uma música.
class MusicaModel {
  // Título da música.
  String title;
  // Autor da música.
  String author;
  // URL do arquivo de música.
  String url;
  // Duração da música em segundos.
  double duration;

  // Construtor da classe, exige todos os campos como obrigatórios.
  MusicaModel({
    required this.title,
    required this.author,
    required this.url,
    required this.duration,
  });

  // Fábrica para criar uma instância de MusicaModel a partir de um Map (JSON).
  factory MusicaModel.fromJson(Map<String, dynamic> json) {
    // Obtém a duração como string (ex: "03:45").
    String durationStr = json['duration'] as String;
    // Divide a string em minutos e segundos.
    List<String> parts = durationStr.split(':');
    double durationInSeconds = 0;
    // Se a duração está no formato "mm:ss", converte para segundos.
    if (parts.length == 2) {
      int minutes = int.tryParse(parts[0]) ?? 0;
      int seconds = int.tryParse(parts[1]) ?? 0;
      durationInSeconds = (minutes * 60 + seconds).toDouble();
    }
    // Retorna uma nova instância de MusicaModel com os dados convertidos.
    return MusicaModel(
      title: json['title'] as String,
      author: json['author'] as String,
      url: json['url'] as String,
      duration: durationInSeconds,
    );
  }
}