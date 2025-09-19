class ApiEndpoints {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login"; // Tambahkan endpoint login
  static const String profile = "$baseUrl/profile"; // Contoh endpoint lain
  static const String profileEdit =
      "$baseUrl/profile/photo"; // Contoh endpoint lain

  static const String checkIn =
      "$baseUrl/absen/check-in"; // Endpoint untuk absen masuk
  static const String checkOut =
      "$baseUrl/absen/check-out"; // Endpoint untuk absen masuk
  static const String absenToday =
      "$baseUrl/absen/today"; // Endpoint untuk data absen hari ini
  static const String getStatistik =
      "$baseUrl/absen/stats"; // Endpoint untuk data absen hari ini
  static const String izin =
      "$baseUrl/izin"; // Endpoint untuk data absen hari ini
}
