import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/Dashboard/UI/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text("Dashboard"),)),
    );
  }
}