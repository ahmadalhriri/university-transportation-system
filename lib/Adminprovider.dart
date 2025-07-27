import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';

class AdminProvider with ChangeNotifier {
  final Crud _crud = Crud();
  List<dynamic> _admins = [];

  List<dynamic> get admins => _admins;

  Future<void> fetchAdmins() async {
    var response = await _crud.getrequest(linkadmin);
    if (response != null && response['status'] == 'success') {
      _admins = response['admins'];
      notifyListeners();
    } 
    else
     {
      print('Failed to get admins');
    }
  }
}
