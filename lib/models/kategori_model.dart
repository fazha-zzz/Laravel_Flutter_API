import 'dart:convert';

KategoriModel kategoriFromJson(String str) => KategoriModel.fromJson(json.decode(str));

String KategoriModelToJson(KategoriModel data) => json.encode(data.toJson());

class KategoriModel {
  List<DataKategori>? data;
  String? message;
  bool? success;

  KategoriModel({this.data, this.message, this.success});

  factory KategoriModel.fromJson(Map<String, dynamic> json) => KategoriModel(
    data: json["data"] == null
        ? []
        : List<DataKategori>.from(json["data"]!.map((x) => DataKategori.fromJson(x))),
    message: json["message"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "success": success,
  };
}

class DataKategori {
  int? id;
  String? nama;
  DateTime? createdAt;
  DateTime? updatedAt;

  DataKategori({this.id, this.nama, this.createdAt, this.updatedAt});

  factory DataKategori.fromJson(Map<String, dynamic> json) => DataKategori(
    id: json["id"],
    nama: json["nama"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
