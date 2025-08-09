import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/Dashboard/UI/dasboard_screen.dart';
import 'Dashboard/Dependencies/dashboard_binding.dart';
import 'Resources/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => DashboardScreen(), binding: DashboardBinding()),
      ],
      theme: appTheme,
    );
  }
}