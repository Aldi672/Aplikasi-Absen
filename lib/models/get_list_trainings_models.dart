// To parse this JSON data, do
//
//     final trainings = trainingsFromJson(jsonString);

import 'dart:convert';

Trainings trainingsFromJson(String str) => Trainings.fromJson(json.decode(str));

String trainingsToJson(Trainings data) => json.encode(data.toJson());

class Trainings {
  String? message;
  List<Datum>? data;

  Trainings({this.message, this.data});

  factory Trainings.fromJson(Map<String, dynamic> json) => Trainings(
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? title;

  Datum({this.id, this.title});

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
