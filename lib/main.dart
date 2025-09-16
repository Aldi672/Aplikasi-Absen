import 'package:aplikasi_absen/screens/pages_akun/get_login_screen.dart';
import 'package:aplikasi_absen/screens/pages_akun/get_register_screen.dart';
import 'package:aplikasi_absen/screens/pages_detail/get_dashboard_screen.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: GetLoginScreen.routeName,

      routes: {
        GetLoginScreen.routeName: (context) => const GetLoginScreen(),
        GetRegisterScreen.routeName: (context) => const GetRegisterScreen(),
      },
    );
  }
}
