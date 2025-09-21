// To parse this JSON data, do
//
//     final getDelete = getDeleteFromJson(jsonString);

import 'dart:convert';

GetDelete getDeleteFromJson(String str) => GetDelete.fromJson(json.decode(str));

String getDeleteToJson(GetDelete data) => json.encode(data.toJson());

class GetDelete {
  String? message;
  Data? data;

  GetDelete({this.message, this.data});

  factory GetDelete.fromJson(Map<String, dynamic> json) => GetDelete(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? id;

  Data({this.id});

  factory Data.fromJson(Map<String, dynamic> json) => Data(id: json["id"]);

  Map<String, dynamic> toJson() => {"id": id};
}
