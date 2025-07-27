import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final Crud _crud = Crud();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  login() async {
    isLoading = true;
    setState(() {});

    try {
      var response = await _crud.postrequest(linkLogin, {
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      if (response != null && response['status'] == 'success') {
        print('Login Success: ${response['message']}');

        Provider.of<UserProvider>(context, listen: false)
            .setUserId(response['id'].toString());
        Provider.of<UserProvider>(context, listen: false).setUserData(
            response['username'].toString(),
            response['academic_id'].toString());

        // Navigate based on the role
        if (response['role'] == 'admin') {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('admin', (route) => false);
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('home', (route) => false);
        }
      } else if (response != null && response['status'] == 'not_activated') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Your account isn't activated !"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Invalid user name or password!'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
        print('Login Failed');
      }
    } catch (e) {
      print('catch Error: $e');
    }
    isLoading = false;
    setState(() {});
  }

  void openSignin() {
    Navigator.of(context).pushReplacementNamed("RegisterScreen");
  }

  final _formkey = GlobalKey<FormState>();
  void validation() async {
    if (_formkey.currentState!.validate()) {
      await login();
    }
  }

  @override
  Widget build(BuildContext context) {
    int back = int.parse("0xFF" "C9D6DF");
    
    int field = int.parse("0xFF" "F0F5F9");

    return Scaffold(
      backgroundColor: Color(back),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: Form(
                  key: _formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 305.0, // عرض الحاوية التي ستظهر كحدود
                          height: 305.0,
                          decoration: const BoxDecoration(
                            color: Colors.black, // لون الحدود
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
                        const SizedBox(height: 15),
                        Text(
                          "Login to your Account",
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          //    height: 150,
                          width: 400,
                          child: TextFormField(
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter user name'
                                : null,
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              prefix: const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 4, 137, 246),
                              ),
                              labelText: "UserName",
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Color(field),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              enabled: true,
                              prefix: const Icon(
                                Icons.lock_sharp,
                                color: Color.fromARGB(255, 4, 137, 246),
                              ),
                              labelText: "Password",
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Color(field),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: MaterialButton(
                              minWidth: 150,
                              child: Text(
                                "Login",
                                style: GoogleFonts.robotoCondensed(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: validation),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.robotoCondensed(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: openSignin,
                              child: Text(
                                "Register",
                                style: GoogleFonts.robotoCondensed(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
