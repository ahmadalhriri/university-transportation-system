// ignore_for_file: unused_import
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../components/crud.dart';
import '../constant/linkapi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LoadImage extends StatefulWidget {
  const LoadImage({super.key});

  @override
  _LoadImageState createState() => _LoadImageState();
}

class _LoadImageState extends State<LoadImage> {
  String img = 'images/prgm.png';
  bool isloading = false;
  final Crud _crud = Crud();
  String selected_img = "No image selected";

  addingImgPath() async {
    try {
      String? userId = Provider.of<UserProvider>(context, listen: false).userId;
      print('User ID in addingImgPath: $userId'); // Debugging statement
      var response = await _crud.postrequest(linkimage, {
        'url': 'image_path',
        'id_account': userId, // Include the user ID
      });

      print('Response: $response'); // Print the entire response for debugging

      if (response != null && response['status'] == 'success') {
        print('Success');
      } else {
        print('Failed to send data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<String> path = [];
  String _responseMessage = '';
  String _responseMessage_end_con = '';
  Future<void> sendData() async {
    final url = Uri.parse('http://192.168.84.116:3000/my-python-function');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'numbers': path}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _responseMessage = responseData['numbers'].toString();
        print(_responseMessage);
        end_connection();
      });
    } else {
      setState(() {
        _responseMessage = 'فشل في الحصول على استجابة';
      });
    }
  }

  Future<void> end_connection() async {
    final url = Uri.parse('http://10.2.0.2:3000/shutdown');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      setState(() {
        // التحقق إذا كانت الاستجابة تحتوي على قيمة صالحة
        if (responseData['res'] != null &&
            responseData['res'].isNotEmpty &&
            responseData['res'] !=
                'python, I received this: enter correct image') {
          _responseMessage_end_con = responseData['res'].toString();
          final res = _responseMessage_end_con
              .replaceAll("'", '"')
              .replaceAll("(", "[")
              .replaceAll(")", "]");

          // تحويل النص إلى خريطة باستخدام json.decode
          Map<String, dynamic> resMap;
          List<String> days = [];
          List<List<int>> times = [];
          String? userId =
              Provider.of<UserProvider>(context, listen: false).userId;

          try {
            resMap = json.decode(res);

            // استخراج الأيام والأوقات في قوائم
            days = resMap.keys.toList(); // قائمة بالأيام
            times = resMap.values
                .map((e) => List<int>.from(e))
                .toList(); // قائمة بالأوقات
          } catch (e) {
            print("خطأ في التحويل: $e");
          }
          /////////////////////////////////////////////
          for (int i = 0; i < days.length; i++) {
            print(times[i][0]);
            print(times[i][1]);
            print(days[i]);
            final Crud _crud = Crud();
            final _startController = times[i][0];
            final _endController = times[i][1];
            final _daysController = days[i];
            save_ocr_result() async {
              setState(() {});
              try {
                var response = await _crud.postrequest(linksaveOcrResult, {
                  'start': _startController.toString(),
                  'end': _endController.toString(),
                  'day': _daysController.toString(),
                  'id_account': userId
                });
                setState(() {});
                if (response['status'] == 'success') {
                  print('data insert');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('The image uploaded successfully')));
                } else {
                  print('Faild to send data');
                }
              } catch (e) {
                print('catch Errorrrrr $e');
              }
            }

            save_ocr_result();
          }
          ///////////////////////////////////////////////////
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('your image is not appropriate ')));
          _responseMessage_end_con =
              'الرجاء إدخال صورة صالحة قبل إنهاء الاتصال.';
        }
      });
    } else {
      setState(() {
        _responseMessage_end_con = 'فشل في إيقاف الخادم';
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage(BuildContext context) async {
    var pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        path.add(_image!.path);
        if (kDebugMode) {
          print("Path of image : ${_image!.path}");
        }
      });
    }
  }

  int back = int.parse("0xFF" "C9D6DF");
  int ColorButtomLoadImag = int.parse("0xFF" "B4D4FF");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:Colors.blueGrey[300],
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        primary: false,
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            "Loading Image",
            style: TextStyle(color: Colors.black),
          ),
        ),

        //  backgroundColor: Colors.black,
        elevation: 0,
      ),

      /////////////////////////////////////////////////////////////////
      body: Container(
        color: Color(back),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(ColorButtomLoadImag))),
                onPressed: () {
                  _pickImage(context);
                },
                child: const Text(
                  " Press here to choose image of your program ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            /*Container(
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue[400])),
                onPressed: () async {
                  await addingImgPath();
                },
                child: const Text(
                  "Send",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),*/
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: Center(
                child: _image != null
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(20),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green)),
                                onPressed: () {
                                  sendData();
                                },
                                child: const Text(
                                  "Upload image",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(selected_img),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
