class Donation {
  final int id;
  final String nama;
  final String gambar;
  final String deskripsi;
  final double targetTerkumpul;

  Donation({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.deskripsi,
    required this.targetTerkumpul,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      nama: json['nama'],
      gambar: json['gambar'],
      deskripsi: json['deskripsi'],
      targetTerkumpul: double.parse(json['target_terkumpul'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'gambar': gambar,
      'deskripsi': deskripsi,
      'target_terkumpul': targetTerkumpul,
    };
  }
}
