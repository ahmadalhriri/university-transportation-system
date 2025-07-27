import 'package:flutter/material.dart';
import 'package:flutter_application_2/Adminprovider.dart';
import 'package:flutter_application_2/admin/EnterTable.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/admin/dataTable.dart';
import 'package:flutter_application_2/admin/search.dart';
import 'package:flutter_application_2/admin/showtable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/user_provider.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Search(),
    const datatable(),
    TransportApp()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminId = Provider.of<UserProvider>(context, listen: false).userId;
      if (adminId != null) {
        Provider.of<UserProvider>(context, listen: false)
            .fetchAccounts(adminId);
        Provider.of<AdminProvider>(context, listen: false).fetchAdmins();
      }
    });
  }

  void gobacklogin() {
    Navigator.of(context).pushReplacementNamed("gobacklogin");
  }

  int back = int.parse("0xFF" "C9D6DF");
  final int SelectedIcon = int.parse("0xFF" "7AB2D3");
  int unselectedIcon = int.parse("0xFF" "C9D6DF");
  int bottombar = int.parse("0xFF" "176B87");
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

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(back),
        iconTheme: const IconThemeData(color: Colors.black, weight: 800),
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          selectedFontSize: 17,
          unselectedItemColor: Colors.grey[100],
          backgroundColor: Color(bottombar),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Schedule table',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Trip Table',
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(back),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[400]),
                    accountName: adminProvider.admins.isNotEmpty
                        ? Text(adminProvider.admins.first['username'])
                        : const Text("Admin Page"),
                    currentAccountPicture:
                        const CircleAvatar(child: Icon(Icons.person)),
                    accountEmail: null,
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(5),
                color: Colors.white,
                height: 50,
                child: InkWell(
                  onTap: logout,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 30,
                      ),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
