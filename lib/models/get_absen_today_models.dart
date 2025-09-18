// To parse this JSON data, do
//
//     final dataAbsen = dataAbsenFromJson(jsonString);

import 'dart:convert';

DataAbsen dataAbsenFromJson(String str) => DataAbsen.fromJson(json.decode(str));

String dataAbsenToJson(DataAbsen data) => json.encode(data.toJson());

class DataAbsen {
  String message;
  Data data;

  DataAbsen({required this.message, required this.data});

  factory DataAbsen.fromJson(Map<String, dynamic> json) =>
      DataAbsen(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  DateTime attendanceDate;
  String checkInTime;
  dynamic checkOutTime;
  String checkInAddress;
  dynamic checkOutAddress;
  String status;
  String alasanIzin;

  Data({
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    attendanceDate: DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
