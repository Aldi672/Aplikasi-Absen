// To parse this JSON data, do
//
//     final editPhoto = editPhotoFromJson(jsonString);

import 'dart:convert';

EditPhoto editPhotoFromJson(String str) => EditPhoto.fromJson(json.decode(str));

String editPhotoToJson(EditPhoto data) => json.encode(data.toJson());

class EditPhoto {
  String? message;
  Data? data;

  EditPhoto({this.message, this.data});

  factory EditPhoto.fromJson(Map<String, dynamic> json) => EditPhoto(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? profilePhoto;

  Data({this.profilePhoto});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
