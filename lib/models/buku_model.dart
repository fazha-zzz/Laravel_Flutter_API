import 'dart:convert';

List<Buku> bukuListFromJson(String str) =>
    List<Buku>.from(json.decode(str)["data"].map((x) => Buku.fromJson(x)));

class Buku {
  final int id;
  final String? kodeBuku; // Changed to nullable
  final String? judul; // Changed to nullable
  final String? penulis; // Changed to nullable
  final String? penerbit; // Changed to nullable
  final int? tahunTerbit; // Changed to nullable
  final int? stok; // Changed to nullable
  final String? foto;
  final Kategori? kategori;

  Buku({
    required this.id,
    this.kodeBuku, // Removed required
    this.judul, // Removed required
    this.penulis, // Removed required
    this.penerbit, // Removed required
    this.tahunTerbit, // Removed required
    this.stok, // Removed required
    this.foto,
    this.kategori,
  });

  factory Buku.fromJson(Map<String, dynamic> json) => Buku(
    id: json["id"] ?? 0, // Provide default value for id
    kodeBuku: json["kode_buku"],
    judul: json["judul"],
    penulis: json["penulis"],
    penerbit: json["penerbit"],
    tahunTerbit: json["tahun_terbit"],
    stok: json["stok"],
    foto: json["foto"],
    kategori: json["kategori"] == null
        ? null
        : Kategori.fromJson(json["kategori"]),
  );

  // Helper methods untuk mendapatkan nilai dengan default
  String get displayJudul => judul ?? 'Judul tidak tersedia';
  String get displayPenulis => penulis ?? 'Tidak tersedia';
  String get displayPenerbit => penerbit ?? 'Tidak tersedia';
  String get displayKodeBuku => kodeBuku ?? 'Tidak tersedia';
  int get displayTahunTerbit => tahunTerbit ?? 0;
  int get displayStok => stok ?? 0;
}

class Kategori {
  final int id;
  final String? nama; // Changed to nullable

  Kategori({
    required this.id,
    this.nama, // Removed required
  });

  factory Kategori.fromJson(Map<String, dynamic> json) =>
      Kategori(id: json["id"] ?? 0, nama: json["nama_kategori"]);

  // Helper method
  String get displayNama => nama ?? 'Tidak tersedia';
}
