// lib/models/reset_password_model.dart

import 'dart:convert';

ResetPasswordResponse resetPasswordFromJson(String str) =>
    ResetPasswordResponse.fromJson(json.decode(str));

String resetPasswordToJson(ResetPasswordResponse data) =>
    json.encode(data.toJson());

class ResetPasswordResponse {
  String? message;

  ResetPasswordResponse({this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ResetPasswordResponse(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
