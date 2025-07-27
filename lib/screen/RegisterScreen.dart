import 'package:flutter/material.dart';
import 'package:flutter_application_2/Adminprovider.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/user_provider.dart';

import 'package:flutter_application_2/constant/linkapi.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  final Crud _crud = Crud();
  bool isLoading = false;
  final _idController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAdmins();
    });
  }

  signUp() async {
    if (_selectedValue == null) {
      print('Please select an admin');
      return;
    }

    isLoading = true;
    setState(() {});

    try {
      var response = await _crud.postrequest(linkSignUp, {
        'academic_id': _idController.text,
        'password': _passwordController.text,
        'id_admin': _selectedValue,
        'username': _usernameController.text,
      });

      if (response != null && response['status'] == 'success') {
        print('Signup Success: ${response['message']}');
        Provider.of<UserProvider>(context, listen: false)
            .setUserId(response['id_account'].toString());
        Provider.of<UserProvider>(context, listen: false).setUserData(
            response['username'].toString(),
            response['academic_id'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your Account created successfully!')));

        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        print('Signup Failed');
      }
    } catch (e) {
      print('catch Error: $e');
    }
    isLoading = false;
    setState(() {});
  }

  void gobacklogin() {
    Navigator.of(context).pushReplacementNamed("gobacklogin");
  }

  final _formkey = GlobalKey<FormState>();
  void validation() async {
    if (_formkey.currentState!.validate()) {
      await signUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    int textFild = int.parse("0xFF" "000000");
    int back = int.parse("0xFF" "C9D6DF");
    int field = int.parse("0xFF" "F0F5F9");
    int textt = int.parse("0xFF" "000000");

    return Scaffold(
      backgroundColor: Color(back),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: IconButton(
          onPressed: gobacklogin,
          iconSize: 33,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Color(back),
        elevation: 0,
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Center(
                  child: Form(
                key: _formkey,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 305.0,
                          height: 305.0,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                "images/logo.png",
                                fit: BoxFit.cover,
                                width: 300,
                                height: 300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text("Register your Account",
                            style: GoogleFonts.robotoCondensed(
                              color: Color(textt),
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Consumer<AdminProvider>(
                          builder: (context, adminProvider, child) {
                            return adminProvider.admins.isEmpty
                                ? const CircularProgressIndicator()
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    width: 400,
                                    child: DropdownButtonFormField<String>(
                                      validator: (value) =>
                                          value == null || value.isEmpty
                                              ? "Pleas Enter the company"
                                              : null,
                                      value: _selectedValue,
                                      hint: const Text('Select an admin'),
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        enabledBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        prefixIcon: Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.blue[300],
                                        ),
                                        labelStyle: const TextStyle(
                                            color: Color(
                                                0xFF000000)), // Replace with your color variable
                                        filled: true,
                                        fillColor: const Color(
                                            0xFFE0E0E0), // Replace with your color variable
                                      ),
                                      items: adminProvider.admins
                                          .map<DropdownMenuItem<String>>(
                                              (admin) {
                                        return DropdownMenuItem<String>(
                                          value: admin['id'].toString(),
                                          child: Text(admin['username']),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedValue = newValue;
                                        });
                                      },
                                    ),
                                  );
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 400,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Pleas enter User Name";
                              } else if (!RegExp(r'^[a-zA-Z]+$')
                                  .hasMatch(value)) {
                                return "User Name must contain letters only";
                              }

                              return null;
                            },
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              prefix: Icon(
                                Icons.person,
                                color: Colors.blue[300],
                              ),
                              labelText: "User Name",
                              labelStyle: TextStyle(color: Color(textFild)),
                              filled: true,
                              fillColor: Color(field),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 400,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Pleas enter Academic ID";
                              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return "Academic ID must contain numbers only";
                              }

                              return null;
                            },
                            controller: _idController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              prefix: Icon(
                                Icons.numbers_outlined,
                                color: Colors.blue[300],
                              ),
                              labelText: "Academic ID",
                              labelStyle: TextStyle(color: Color(textFild)),
                              filled: true,
                              fillColor: Color(field),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 400,
                          child: TextFormField(
                            validator: (value) => value == null || value.isEmpty
                                ? "Pleas enter password"
                                : null,
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              prefix: Icon(
                                Icons.lock_sharp,
                                color: Colors.blue[300],
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Color(textFild)),
                              filled: true,
                              fillColor: Color(field),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                            height: 40,
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: MaterialButton(
                                minWidth: 150,
                                child: Text("Done",
                                    style: GoogleFonts.robotoCondensed(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )),
                                onPressed: validation)),
                      ]),
                ),
              )),
            ),
    );
  }
}
