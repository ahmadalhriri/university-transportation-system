// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Adminprovider.dart';
import 'package:flutter_application_2/admin/EnterTable.dart';
import 'package:flutter_application_2/admin/Admin.dart';
import 'package:flutter_application_2/admin/dataTable.dart';

import 'package:flutter_application_2/screen/LoginScreen.dart';
import 'package:flutter_application_2/student/LoadImage.dart';
import 'package:flutter_application_2/screen/RegisterScreen.dart';
import 'package:flutter_application_2/student/HomeStudent.dart';
import 'package:flutter_application_2/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            "RegisterScreen": (context) => const Register(),
            "/": (context) => LoginScreen(),
            "gobacklogin": (context) => LoginScreen(),
            "home": (context) => User(),
            "admin": (context) => const Admin(),
          },
        ));
  }
}
