import 'package:flutter/material.dart';
import 'package:flutter_application_2/student/LoadImage.dart';
import 'package:flutter_application_2/student/usertrip.dart';
import 'package:flutter_application_2/user_provider.dart';
import 'package:provider/provider.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LoadImage(), // صفحة تحميل الصور
    const UserTrip() // صفحة جدول الرحلات
  ];

  void gobacklogin() {
    Navigator.of(context).pushReplacementNamed("gobacklogin");
  }

  void logout() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: AlertDialog(
              backgroundColor: const Color(0xFFC9D6DF),
              title: const Text(
                "Do you want to log out ? ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    child: const Text(
                      "Cancle",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    onPressed: gobacklogin,
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  int back = int.parse("0xFF" "C9D6DF");
  int ColorButtomBar = int.parse("0xFF" "176B87");
  @override
  Widget build(BuildContext context) {
    final String? userAcademicId =
        Provider.of<UserProvider>(context, listen: false).userAcademicId;
    final String? UserName =
        Provider.of<UserProvider>(context, listen: false).userName;
    return Scaffold(
      appBar: (AppBar(
        backgroundColor: Color(back),
        iconTheme: const IconThemeData(color: Colors.black, weight: 800),
        title: const Text("User Profile"),
      )),
      body: _pages[_currentIndex], // عرض الصفحة بناءً على العنصر المحدد
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        selectedFontSize: 17,
        unselectedItemColor: Colors.grey[100],
        backgroundColor: Color(ColorButtomBar),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // تحديث الصفحة عند الضغط
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image), // أيقونة تحميل الصورة
            label: 'Load Image', // تحميل الصورة
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart), // أيقونة جدول الرحلات
            label: 'Trip Table', // جدول الرحلات
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color(back),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(color: Colors.blue[400]),
                accountEmail: Text(UserName!),
                accountName: Text(userAcademicId!),
                currentAccountPicture:
                    const CircleAvatar(child: Icon(Icons.person)),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromARGB(255, 231, 13, 10),
                height: 50,
                child: InkWell(
                  onTap: logout,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.black,
                        size: 30,
                      ),
                      Text(
                        "Log out",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
              /* Container(
                  width: 800,
                  height: 45,
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                  ),
                  child: ListTile(
                    leadingAndTrailingTextStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    trailing: Text(
                      "Log out",
                    ),
                    leading: GestureDetector(
                     //   color: Colors.black,
                      //  padding: EdgeInsets.zero,
                        //iconSize: 35,
                        child: Icon(Icons.logout),
                        onTap: gobacklogin),
                  )),*/
            ],
          ),
        ),
      ),
    );
  }
}
