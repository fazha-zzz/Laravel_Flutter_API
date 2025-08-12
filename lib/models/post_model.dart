// To parse this JSON data, do
//
//     final postModel = postModelFromJson(jsonString);

import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
    bool? success;
    List<DataPost>? data;
    String? massage;

    PostModel({
        this.success,
        this.data,
        this.massage,
    });

    factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataPost>.from(json["data"]!.map((x) => DataPost.fromJson(x))),
        massage: json["massage"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "massage": massage,
    };
}

class DataPost {
    int? id;
    String? title;
    String? foto;
    String? content;
    String? slug;
    int? status;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataPost({
        this.id,
        this.title,
        this.foto,
        this.content,
        this.slug,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory DataPost.fromJson(Map<String, dynamic> json) => DataPost(
        id: json["id"],
        title: json["title"],
        foto: json["foto"],
        content: json["content"],
        slug: json["slug"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "foto": foto,
        "content": content,
        "slug": slug,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
