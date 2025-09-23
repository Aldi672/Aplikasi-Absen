class ApiEndpoints {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login"; // Tambahkan endpoint login
  static const String profile = "$baseUrl/profile";
  static const String profileEdit = "$baseUrl/profile/photo";

  static const String checkIn = "$baseUrl/absen/check-in";
  static const String checkOut = "$baseUrl/absen/check-out";
  static const String absenToday = "$baseUrl/absen/today";
  static const String getStatistik = "$baseUrl/absen/stats";
  static const String izin = "$baseUrl/izin";
  static const String forgot = "$baseUrl/forgot-password";
  static const String reset = "$baseUrl/reset-password";
  static const String history = "$baseUrl/absen/history";
  static String historyById(String id) => "$baseUrl/absen/$id";
}
