import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';

class UserProvider with ChangeNotifier {
  String? _userId, _userAcademicId, _userName;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;

  String? get userId => _userId;
  String? get userAcademicId => _userAcademicId;
  String? get userName => _userName;

  final Crud _crud = Crud();

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setUserData(String userAcademicId, String userName) {
    _userAcademicId = userAcademicId;
    _userName = userName;
    notifyListeners();
  }

  Future<void> fetchAccounts(String adminId) async {
    try {
      print('Fetching accounts for adminId: $adminId'); // Debug statement
      var response = await _crud.getrequest('$linksearch?id_admin=$adminId');
      if (response != null) {
        print('Response: $response'); // Debug statement
        if (response['status'] == 'success') {
          print('Fetched accounts: ${response['accounts']}'); // Debug statement
          _allUsers = List<Map<String, dynamic>>.from(response['accounts']);
          notifyListeners();
        } else {
          print('Failed to load users: ${response['message']}');
        }
      } else {
        print('Response is null');
      }
    } catch (e) {
      print('Catch Error: $e');
    }
  }

  Future<bool> activateAccount(String academicId) async {
    var response = await _crud.postrequest(linkActiviation, {
      'academic_id': academicId,
    });

    if (response != null && response['status'] == 'success') {
      _allUsers = _allUsers.map((user) {
        if (user['academic_id'] == academicId) {
          user['active'] = 1;
        }
        return user;
      }).toList();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
