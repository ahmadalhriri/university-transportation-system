import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';
import 'package:flutter_application_2/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TransportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransportScheduleScreen(),
    );
  }
}

class TransportScheduleScreen extends StatefulWidget {
  @override
  _TransportScheduleScreenState createState() =>
      _TransportScheduleScreenState();
}

class _TransportScheduleScreenState extends State<TransportScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDay;
  String? selectedTime;
  String? selectedType;
  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  final List<String> times = [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17'
  ];
  final List<String> types = ['Go to university', 'Back from university'];

  List<Map<String, String>> trips = [];

  final TextEditingController Type = TextEditingController();
  /////////////////////////////////////////////////////////////////////////
  void get_all_trip() async {
    Data.clear();
    num_of_trips_go.clear();
    attendanceData.clear();
    num_of_trips_back.clear();
    final Crud _crud = Crud();
    final adminId = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      var response = await _crud
          .postrequest(link_get_all_trip, {'id_admin': adminId.toString()});

      // التحقق من أن الاستجابة غير فارغة وتحتوي على المفتاح 'status'
      if (response != null &&
          response.containsKey('status') &&
          response['status'] == 'success') {
        List<dynamic> data = response['data'];

        for (var i = 0; i < 10; i++) {
          num_of_trips_go.add({
            'Saturday': 0,
            'Sunday': 0,
            'Monday': 0,
            'Tuesday': 0,
            'Wednesday': 0,
            'Thursday': 0,
            'Friday': 0
          });
        }
        for (var i = 0; i < 10; i++) {
          num_of_trips_back.add({
            'Saturday': 0,
            'Sunday': 0,
            'Monday': 0,
            'Tuesday': 0,
            'Wednesday': 0,
            'Thursday': 0,
            'Friday': 0
          });
        }
        for (var i = 0; i < data.length; i++) {
          String day = data[i]['day'].toString();
          for (var z = 0; z < 10; z++) {
            if ((z + 8).toString() == data[i]['time'].toString() &&
                data[i]['type'].toString() == 'Go to university') {
              num_of_trips_go[z][day] = (num_of_trips_go[z][day] ?? 0) + 1;
            }
          }
          for (var z = 0; z < 10; z++) {
            if ((z + 8).toString() == data[i]['time'].toString() &&
                data[i]['type'].toString() == 'Back from university') {
              num_of_trips_back[z][day] = (num_of_trips_back[z][day] ?? 0) + 1;
            }
          }
        }

        for (var i = 0; i < data.length; i++) {
          for (var j = 0; j < data.length; j++) {
            if (data[i]['day'].toString() == data[j]['day'].toString() &&
                data[i]['time'].toString() == data[j]['time'].toString() &&
                data[i]['type'].toString() == data[j]['type'].toString() &&
                data[i]['id_admin'].toString() ==
                    data[j]['id_admin'].toString() &&
                i != j) {
              data.removeAt(i);
              j = i = 0;
            }
          }
        }

        for (var i in data) {
          int tm = int.parse(i['time']);
          String day = i['day'].toString(); // اليوم
          if (i['type'].toString() == 'Go to university') {
            attendanceData.add({
              'day': i['day'].toString(),
              'time': i['time'].toString(),
              'type': i['type'].toString(),
              'num_of_trip': num_of_trips_go[(tm - 8)][day].toString()
            });
          } else {
            attendanceData.add({
              'day': i['day'].toString(),
              'time': i['time'].toString(),
              'type': i['type'].toString(),
              'num_of_trip': num_of_trips_back[(tm - 8)][day].toString()
            });
          }
        }

        processAttendanceData();
        setState(() {});
      } else if (response['status'] == 'fail') {
        print('no data');
      } else {
        print('error');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

/////////////////////////////////////////////////////////////////////
  void processAttendanceData() {
    final List<String> days = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ];

    // ignore: unused_local_variable
    final List<int> time = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];
    go_to_univer.clear();
    back_from_univer.clear();

    // فصل البيانات إلى مصفوفتين
    for (var entry in attendanceData) {
      if (entry['type'] == 'Go to university') {
        go_to_univer.add(entry);
      } else if (entry['type'] == 'Back from university') {
        back_from_univer.add(entry);
      }
    }

    // ترتيب المصفوفات حسب اليوم والوقت
    go_to_univer.sort((a, b) {
      int dayComparison =
          days.indexOf(a['day']).compareTo(days.indexOf(b['day']));
      if (dayComparison != 0) return dayComparison;

      // تحويل القيم إلى أرقام إذا كانت نصوصًا
      int timeA = int.tryParse(a['time'].toString()) ?? 0;
      int timeB = int.tryParse(b['time'].toString()) ?? 0;

      return timeA.compareTo(timeB);
    });

    back_from_univer.sort((a, b) {
      int dayComparison =
          days.indexOf(a['day']).compareTo(days.indexOf(b['day']));
      if (dayComparison != 0) return dayComparison;

      // تحويل القيم إلى أرقام إذا كانت نصوصًا
      int timeA = int.tryParse(a['time'].toString()) ?? 0;
      int timeB = int.tryParse(b['time'].toString()) ?? 0;

      return timeA.compareTo(timeB);
    });

    // إضافة عناصر placeholder في البداية
    if (go_to_univer.isNotEmpty) {
      Data.add({
        'time': 'Going to university',
        'day': '',
        'type': '',
        'num_of_trip': '',
      });
      Data.addAll(go_to_univer);
    }

    if (back_from_univer.isNotEmpty) {
      Data.add({
        'time': 'Back from university',
        'day': '',
        'type': '',
        'num_of_trip': '',
      });
      Data.addAll(back_from_univer);
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    get_all_trip();
    // TODO: implement initState
    super.initState();
  }

  ///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////
  void deleteTrip() async {
    final Crud _crud = Crud();
    final adminId = Provider.of<UserProvider>(context, listen: false).userId;

    if (_formKey.currentState!.validate()) {
      setState(() {});
      try {
        var response = await _crud.postrequest(link_delete_trip, {
          'day': selectedDay.toString(),
          'time': selectedTime.toString(),
          'type': selectedType.toString(),
          'id_admin': adminId.toString(), // Pass the admin ID
        });
        setState(() {});
        if (response['status'] == 'success') {
          print('data deleted');
          selectedType = null;
          selectedDay = null;
          selectedTime = null;
          get_all_trip();
        } else {
          print('Failed to deleted data');
        }
      } catch (e) {
        print('Catch Error: $e');
      }
    }
  }

///////////////////////////////////////////////////
  void addTrip() async {
    final Crud _crud = Crud();
    final adminId = Provider.of<UserProvider>(context, listen: false).userId;
    print(
        '////////////////////////////////////////////////////////////////////////////////$adminId');
    if (_formKey.currentState!.validate()) {
      setState(() {});
      try {
        var response = await _crud.postrequest(link_save_trip_table, {
          'day': selectedDay.toString(),
          'time': selectedTime.toString(),
          'type': selectedType.toString(),
          'id_admin': adminId.toString(),
        });
        setState(() {});
        if (response['status'] == 'success') {
          print('data inserted');

          selectedType = null;
          selectedDay = null;
          selectedTime = null;
          get_all_trip();
        } else {
          print('Faild to send data');
        }
      } catch (e) {
        print('catch Errorrrrr $e');
      }
    }
  }

  final List<Map<String, dynamic>> attendanceData = [];
  final List<Map<String, dynamic>> Data = [];
  final List<Map<String, dynamic>> go_to_univer = [];
  final List<Map<String, dynamic>> back_from_univer = [];

  final List<Map<String, int>> num_of_trips_go = [];
  final List<Map<String, int>> num_of_trips_back = [];

  int back = int.parse("0xFF" "C9D6DF");
  int shadowColor = int.parse("0xFF" "0E2954");
  int backgroundcolor = int.parse("0xFF" "176B87");
  int fontColor = int.parse("0xFF" "FFFFFF");
  ////////////////////////////////////
  ///
  int i = 0;
  int feild1 = int.parse("0xFF" "B4D4FF");
  int feild2 = int.parse("0xFF" "86B6F6");
  int tt = int.parse("0xFF" "176B87");
  Color rowcolor = Color(0xFFFFFF);
  int FontTableColor = int.parse("0xFF" "FFFFFF");
  double fontsize = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(back),
      appBar: AppBar(
        title: const Center(child: Text('Entering Table')),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ////
                    Container(
                      decoration: BoxDecoration(
                        color: Color(backgroundcolor), // لون الخلفية
                        borderRadius:
                            BorderRadius.circular(8), // الحواف الدائرية
                        boxShadow: [
                          BoxShadow(
                            color:
                                Color(shadowColor).withOpacity(0.8), // لون الظل
                            blurRadius: 20, // مدى تشويش الظل
                            offset: Offset(0, 5), // إزاحة الظل (X, Y)
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 10),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Color(fontColor)),
                          //    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          labelText: 'Select Day',
                          border: InputBorder.none, // إزالة الحدود الافتراضية
                        ),
                        value: selectedDay,
                        items: days
                            .map((day) =>
                                DropdownMenuItem(value: day, child: Text(day)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDay = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a day' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    //////////////////////
                    Container(
                      decoration: BoxDecoration(
                        color: Color(backgroundcolor), // لون الخلفية
                        borderRadius:
                            BorderRadius.circular(8), // الحواف الدائرية
                        boxShadow: [
                          BoxShadow(
                            color:
                                Color(shadowColor).withOpacity(0.8), // لون الظل
                            blurRadius: 12, // مدى تشويش الظل
                            offset: Offset(0, 5), // إزاحة الظل (X, Y)
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 10),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Color(fontColor)),
                          labelText: 'Select Time',
                          border: InputBorder.none,
                        ),
                        value: selectedTime,
                        items: times
                            .map((time) => DropdownMenuItem(
                                value: time, child: Text(time)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTime = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a time' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    /////////////////////////
                    Container(
                      decoration: BoxDecoration(
                        color: Color(backgroundcolor), // لون الخلفية
                        borderRadius:
                            BorderRadius.circular(8), // الحواف الدائرية
                        boxShadow: [
                          BoxShadow(
                            color:
                                Color(shadowColor).withOpacity(0.8), // لون الظل
                            blurRadius: 12, // مدى تشويش الظل
                            offset: Offset(0, 0), // إزاحة الظل (X, Y)
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 10),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Color(fontColor)),
                          labelText: 'Select Type',
                          border: InputBorder.none,
                        ),
                        value: selectedType,
                        items: types
                            .map((type) => DropdownMenuItem(
                                value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a type' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200, // Adjust the width as needed
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),

                            child: MaterialButton(
                                // minWidth: 150,
                                child: Text(
                                  "Add Trip",
                                  style: GoogleFonts.robotoCondensed(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: addTrip),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 200, // Adjust the width as needed
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            child: MaterialButton(
                                // minWidth: 150,
                                child: Text(
                                  "Delete Trip",
                                  style: GoogleFonts.robotoCondensed(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: deleteTrip),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Time')), // عمود الوقت
                        ...days.map((day) {
                          return DataColumn(label: Text(day));
                        }).toList(), // أعمدة الأيام
                      ],
                      rows: Data.map((entry) {
                        final Color sowColor;
                        if (entry['time'] == ("Going to university") ||
                            entry['time'] == ("Back from university")) {
                          FontTableColor = int.parse("0xFF" "FFFFFF");
                          sowColor = Color(tt);
                          fontsize = 18;
                        } else {
                          FontTableColor = int.parse("0xFF" "000000");
                          fontsize = 14;
                          if (i % 2 == 0) {
                            sowColor = Color(feild1);
                          } else {
                            sowColor = Color(feild2);
                          }
                        }
                        print(i);
                        i += 1;
                        return DataRow(
                            color: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return sowColor; // تحديد اللون
                              },
                            ),
                            cells: [
                              DataCell(Text(
                                entry['time'] ?? '-',
                                style: TextStyle(
                                    color: Color(FontTableColor),
                                    fontSize: fontsize),
                              )), // الوقت
                              ...days.map((day) {
                                // عرض عدد الرحلات إذا كان اليوم متطابقاً
                                if (entry['day'] == day) {
                                  return DataCell(
                                      Text(entry['num_of_trip'] ?? '-'));
                                } else {
                                  return DataCell(
                                      Text('-')); // خلايا فارغة للأيام الأخرى
                                }
                              }).toList(),
                            ]);
                      }).toList(),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
