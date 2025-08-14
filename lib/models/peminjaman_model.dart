class PeminjamanModel {
  final int id;
  final int userId;
  final int bukuId;
  final int stokDipinjam;
  final String tanggalPinjam;
  final String tenggat;
  final String? tanggalPengembalian;
  final String status;
  final UserModel? user;
  final BukuModel? buku;
  final String createdAt;
  final String updatedAt;

  PeminjamanModel({
    required this.id,
    required this.userId,
    required this.bukuId,
    required this.stokDipinjam,
    required this.tanggalPinjam,
    required this.tenggat,
    this.tanggalPengembalian,
    required this.status,
    this.user,
    this.buku,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeminjamanModel.fromJson(Map<String, dynamic> json) {
    return PeminjamanModel(
      id: json['id'],
      userId: json['user_id'],
      bukuId: json['buku_id'],
      stokDipinjam: json['stok_dipinjam'],
      tanggalPinjam: json['tanggal_pinjam'],
      tenggat: json['tenggat'],
      tanggalPengembalian: json['tanggal_pengembalian'],
      status: json['status'],
      user: json['user'] != null
          ? (json['user'] is Map<String, dynamic>
                ? UserModel.fromJson(json['user'])
                : null)
          : null,
      buku: json['buku'] != null
          ? (json['buku'] is Map<String, dynamic>
                ? BukuModel.fromJson(json['buku'])
                : null)
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'buku_id': bukuId,
      'stok_dipinjam': stokDipinjam,
      'tanggal_pinjam': tanggalPinjam,
      'tenggat': tenggat,
      'tanggal_pengembalian': tanggalPengembalian,
      'status': status,
      'user': user?.toJson(),
      'buku': buku?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class BukuModel {
  final int id;
  final String judul;

  BukuModel({required this.id, required this.judul});

  factory BukuModel.fromJson(Map<String, dynamic> json) {
    return BukuModel(id: json['id'], judul: json['judul']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'judul': judul};
  }
}
