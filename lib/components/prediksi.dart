class Prediksi {
  String id;
  final String email;
  final String tanggal;
  final String waktu;
  final List<dynamic> prediksi;
  final String urlgambar;

  Prediksi({
    this.id = '',
    required this.email,
    required this.tanggal,
    required this.waktu,
    required this.prediksi,
    required this.urlgambar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'tanggal': tanggal,
        'waktu': waktu,
        'prediksi': prediksi,
        'urlgambar': urlgambar,
      };

  static Prediksi fromJson(Map<String, dynamic> json) => Prediksi(
      id: json['id'],
      email: json['email'],
      tanggal: json['tanggal'],
      waktu: json['waktu'],
      prediksi: List.from(json['prediksi'] ?? []),
      urlgambar: json['urlgambar']);
}
