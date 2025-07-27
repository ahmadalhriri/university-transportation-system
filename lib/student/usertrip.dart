import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';
import 'package:flutter_application_2/user_provider.dart';
import 'package:provider/provider.dart';

class UserTrip extends StatefulWidget {
  const UserTrip({super.key});

  @override
  State<UserTrip> createState() => _UserTripState();
}

class _UserTripState extends State<UserTrip> {
  @override
  void initState() {
    getStudentTrip();
    super.initState();
  }

  void getStudentTrip() async {
    attendanceData.clear();
    go_to_univer.clear();
    back_from_univer.clear();
    Data.clear();
    final Crud _crud = Crud();
    final id_account = Provider.of<UserProvider>(context, listen: false).userId;

    try {
      var response = await _crud.postrequest(
        link_get_student_trip,
        {'id_account': id_account.toString()},
      );

      if (response != null &&
          response.containsKey('status') &&
          response['status'] == 'success') {
        List<dynamic> data_trip = response['data'];

        var response2 = await _crud.postrequest(
          link_get_student_table,
          {'id_account': id_account.toString()},
        );

        if (response2 != null &&
            response2.containsKey('status') &&
            response2['status'] == 'success') {
          List<dynamic> data_schedul = response2['data'];
          for (var i in data_schedul) {
            if (i['day'].toString() == 'S') {
              i['day'] = 'Saturday';
            } else if (i['day'].toString() == 'Su') {
              i['day'] = 'Sunday';
            } else if (i['day'].toString() == 'M') {
              i['day'] = 'Monday';
            } else if (i['day'].toString() == 'Tu') {
              i['day'] = 'Tuesday';
            } else if (i['day'].toString() == 'W') {
              i['day'] = 'Wednesday';
            }
          }

          for (var i in data_trip) {
            for (var j in data_schedul) {
              if (i['type'] == 'Go to university') {
                if (i['day'].toString() == j['day'].toString() &&
                    i['time'].toString() == j['start'].toString()) {
                  attendanceData.add({
                    'time': i['time'],
                    'day': i['day'],
                    'type': 'Going to university',
                  });
                }
              }
            }
          }

          for (var i in data_trip) {
            for (var j in data_schedul) {
              if (i['type'] == 'Back from university') {
                if (i['day'].toString() == j['day'].toString() &&
                    i['time'].toString() == j['end'].toString()) {
                  attendanceData.add({
                    'time': i['time'],
                    'day': i['day'],
                    'type': 'Back from university',
                  });
                }
              }
            }
          }
          setState(() {
            processAttendanceData();
          });
        } else if (response2['status'] == 'fail') {
          print('no schedul');
        } else {
          print('error');
        }
      } else if (response['status'] == 'fail') {
        print('no trip');
      } else {
        print('error');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

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

    go_to_univer.clear();
    back_from_univer.clear();

    for (var entry in attendanceData) {
      if (entry['type'] == 'Going to university') {
        go_to_univer.add(entry);
      } else if (entry['type'] == 'Back from university') {
        back_from_univer.add(entry);
      }
    }

    go_to_univer.sort((a, b) {
      int dayComparison =
          days.indexOf(a['day']).compareTo(days.indexOf(b['day']));
      if (dayComparison != 0) return dayComparison;

      int timeA = int.tryParse(a['time'].toString()) ?? 0;
      int timeB = int.tryParse(b['time'].toString()) ?? 0;

      return timeA.compareTo(timeB);
    });

    back_from_univer.sort((a, b) {
      int dayComparison =
          days.indexOf(a['day']).compareTo(days.indexOf(b['day']));
      if (dayComparison != 0) return dayComparison;

      int timeA = int.tryParse(a['time'].toString()) ?? 0;
      int timeB = int.tryParse(b['time'].toString()) ?? 0;

      return timeA.compareTo(timeB);
    });

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
      print(Data);
    }
  }

  final List<Map<String, dynamic>> Data = [];
  final List<Map<String, dynamic>> attendanceData = [];
  final List<Map<String, dynamic>> go_to_univer = [];
  final List<Map<String, dynamic>> back_from_univer = [];

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
      appBar: AppBar(
        title: Center(child: const Text('Trips Schedule')),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context)
                  .size
                  .height, // جعل العرض يتماشى مع عرض الجهاز
              child: DataTable(
                columnSpacing: 20, // مسافة بين الأعمدة
                columns: const [
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Day')),
                  DataColumn(label: Text('Type')),
                ],
                rows: Data.map((entry) {
                  final Color sowColor;
                  if (entry['time'] == ("Going to university") ||
                      entry['time'] == ("Back from university")) {
                    print(entry['time']);
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
                            color: Color(FontTableColor), fontSize: fontsize),
                      )),
                      DataCell(Text(entry['day'] ?? '-')),
                      DataCell(Text(entry['type'] ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
