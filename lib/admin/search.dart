import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/user_provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminId = Provider.of<UserProvider>(context, listen: false).userId;
      if (adminId != null) {
        Provider.of<UserProvider>(context, listen: false)
            .fetchAccounts(adminId)
            .then((_) {
          setState(() {
            _foundUsers =
                Provider.of<UserProvider>(context, listen: false).allUsers;
            print('Found users: $_foundUsers'); // Debug statement
          });
        });
      }
    });
  }

  void _runFilter(String enteredKeyword) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    List<Map<String, dynamic>> results = [];

    if (enteredKeyword.isEmpty) {
      results = userProvider.allUsers;
    } else {
      results = userProvider.allUsers
          .where((user) => user["username"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  void _showActivationDialog(String academicId, String username) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Are you sure to activate this account?  $username"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _activateAccount(academicId);
                },
                child: Text(
                  "Activate",
                  style: GoogleFonts.robotoCondensed(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.robotoCondensed(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _activateAccount(String academicId) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    bool success = await userProvider.activateAccount(academicId);

    if (success) {
      setState(() {
        _foundUsers = userProvider.allUsers;
        _foundUsers.removeWhere((user) => user['academic_id'] == academicId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account activated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to activate account.')),
      );
    }
  }

  int back = int.parse("0xFF" "C9D6DF");
  int field = int.parse("0xFF" "F0F5F9");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Activation Account")),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Color(back),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return _foundUsers.isNotEmpty
                      ? ListView.builder(
                          itemCount: _foundUsers.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(_foundUsers[index]["academic_id"]),
                            color: Colors.blue,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Text(
                                index.toString(),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              subtitle: Text(
                                _foundUsers[index]["academic_id"].toString(),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              title: Text(
                                _foundUsers[index]['username'].toString(),
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                              trailing: IconButton(
                                color: Color.fromARGB(255, 12, 241, 24),
                                onPressed: () {
                                  _showActivationDialog(
                                      _foundUsers[index]['academic_id']
                                          .toString(),
                                      _foundUsers[index]['username']
                                          .toString());
                                },
                                iconSize: 30,
                                icon: const Icon(Icons.check_circle_outline),
                              ),
                            ),
                          ),
                        )
                      : const Text(
                          'No results found',
                          style: TextStyle(fontSize: 24),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
