import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/crud.dart';
import 'package:flutter_application_2/constant/linkapi.dart';
import 'package:flutter_application_2/user_provider.dart';
import 'package:provider/provider.dart';

class datatable extends StatefulWidget {
  const datatable({super.key});

  @override
  State<datatable> createState() => _datatableState();
}

class _datatableState extends State<datatable> {
  int i = 0;

  ///////////////////////
  int c = 1;
  final Map<String, Map<String, int>> startCountsPerDay = {};
  final Map<String, Map<String, int>> endCountsPerDay = {};

  @override
  void initState() {
    getAllOcrResult();
    super.initState();
  }

  ////////////////////////////////////////////////////////////
  Future<void> getAllOcrResult() async {
    final Crud _crud = Crud();
    final adminId = Provider.of<UserProvider>(context, listen: false).userId;
    var response =
        await _crud.postrequest(link_get_ocr_result, {'id_admin': adminId});

    if (response != null && response['status'] == 'success') {
      List<dynamic> data = response['data'];
      //data.insert(0, 'gp');
      print("OCR Results:");

      calculateStartEndCounts(data);
    } else {
      print("Failed to retrieve OCR results");
    }
  }

  void calculateStartEndCounts(List<dynamic> schedules) {
    for (var schedule in schedules) {
      String day = schedule['day'];
      int start = schedule['start'];
      int end = schedule['end'];

      String startTime = '$start';
      String endTime = '$end';

      if (!startCountsPerDay.containsKey(day)) {
        startCountsPerDay[day] = {};
      }
      if (!endCountsPerDay.containsKey(day)) {
        endCountsPerDay[day] = {};
      }

      startCountsPerDay[day]![startTime] =
          (startCountsPerDay[day]![startTime] ?? 0) + 1;

      endCountsPerDay[day]![endTime] =
          (endCountsPerDay[day]![endTime] ?? 0) + 1;
    }

    /*
  startCountsPerDay.forEach((day, startCounts) {
    print("\nStart Times Count for $day:");
    startCounts.forEach((time, count) {
      print('$time - $count students');
    });
  });

  endCountsPerDay.forEach((day, endCounts) {
    print("\nEnd Times Count for $day:");
    endCounts.forEach((time, count) {
      print('$time - $count students');
    });
  });
  */
    ///////////////////////////////////

    void sortDataByDay() {
      // نقوم بترتيب الأيام حسب الترتيب المعتاد (الأحد -> الاثنين -> الثلاثاء -> ...)
      List<String> orderedDays = ['S', 'Su', 'M', 'Tu', 'W'];

      // دالة لترتيب الأوقات بداخل كل يوم
      Map<String, int> sortTimes(Map<String, int> times) {
        var sortedTimes = Map.fromEntries(times.entries.toList()
          ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key))));
        return sortedTimes;
      }

      // إعادة ترتيب startCountsPerDay حسب الأيام وترتيب الأوقات بداخل كل يوم
      Map<String, Map<String, int>> sortedData = {};

      for (var day in orderedDays) {
        if (startCountsPerDay.containsKey(day)) {
          sortedData[day] = sortTimes(startCountsPerDay[day]!);
        }
      }

      setState(() {
        startCountsPerDay.clear();
        startCountsPerDay.addAll(sortedData);
      });

      Map<String, Map<String, int>> sortedData2 = {};

      for (var day in orderedDays) {
        if (endCountsPerDay.containsKey(day)) {
          sortedData2[day] = sortTimes(endCountsPerDay[day]!);
        }
      }

      setState(() {
        endCountsPerDay.clear();
        endCountsPerDay.addAll(sortedData2);
      });

      print("Sorted startCountsPerDay:");
      print(startCountsPerDay);
      print("Sorted endCountsPerDay:");
      print(endCountsPerDay);
    }

    void addMissingData() {
      List<String> orderedDays = ['S', 'Su', 'M', 'Tu', 'W'];

      List<String> allHours = [];

      startCountsPerDay.forEach((day, times) {
        times.keys.forEach((hour) {
          if (!allHours.contains(hour)) {
            allHours.add(hour);
          }
        });
      });

      orderedDays.forEach((day) {
        if (!startCountsPerDay.containsKey(day)) {
          startCountsPerDay[day] = {};
        }

        allHours.forEach((hour) {
          if (!startCountsPerDay[day]!.containsKey(hour)) {
            startCountsPerDay[day]![hour] = 0;
          }
        });
      });
///////////////////////////////////
      allHours = [];
      endCountsPerDay.forEach((day, times) {
        times.keys.forEach((hour) {
          if (!allHours.contains(hour)) {
            allHours.add(hour);
          }
        });
      });

      orderedDays.forEach((day) {
        if (!endCountsPerDay.containsKey(day)) {
          endCountsPerDay[day] = {};
        }

        allHours.forEach((hour) {
          if (!endCountsPerDay[day]!.containsKey(hour)) {
            endCountsPerDay[day]![hour] = 0;
          }
        });
      });
      /////////////////////////////////////////////////
    }

    addMissingData();
    sortDataByDay();

////////////////////////////////////////////////////

    setState(() {
      attendanceData.add({'time': ''});
      S.add('');
      Su.add('');
      M.add('');
      Tu.add('');
      W.add('');
      startCountsPerDay.forEach((day, times) {
        bool flack = false;
        times.forEach((hour, count) {
          attendanceData.forEach((time1) {
            if (time1['time'] == hour) {
              flack = true;
            }
          });
          if (flack == false) {
            attendanceData.add({'time': hour});
          }

          if (day == 'S') {
            S.add(count.toString());
          } else if (day == 'Su') {
            Su.add(count.toString());
          } else if (day == 'M') {
            M.add(count.toString());
          } else if (day == 'Tu') {
            Tu.add(count.toString());
          } else if (day == 'W') {
            W.add(count.toString());
          }
        });
      });
      attendanceData.add({'time': ''});
      S.add('');
      Su.add('');
      M.add('Back from university');
      Tu.add('');
      W.add('');
      final List<Map<String, dynamic>> check = [];

      endCountsPerDay.forEach((day, times) {
        times.forEach((hour, count) {
          bool flack = false;
          check.forEach((time1) {
            if (time1['time'] == hour) {
              flack = true;
            }
          });
          if (flack == false) {
            attendanceData.add({'time': hour});
            check.add({'time': hour});
          }
          if (day == 'S') {
            S.add(count.toString());
          } else if (day == 'Su') {
            Su.add(count.toString());
          } else if (day == 'M') {
            M.add(count.toString());
          } else if (day == 'Tu') {
            Tu.add(count.toString());
          } else if (day == 'W') {
            W.add(count.toString());
          }
        });
      });
    });
  }

  /////////////////////////////////////////////////////
  final List<Map<String, dynamic>> attendanceData = [];
  final List<String> S = [];
  final List<String> Su = [];
  final List<String> M = [];
  final List<String> Tu = [];
  final List<String> W = [];

  int back = int.parse("0xFF" "C9D6DF");
  int feild1 = int.parse("0xFF" "B4D4FF");
  int feild2 = int.parse("0xFF" "86B6F6");
  int tt = int.parse("0xFF" "176B87");
  int colorfont = int.parse("0xFF" "000000");
  double fontsize = 14;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(back),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(child: Text(' Student Timetable')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            //  width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height*0.75,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('time')),
                  DataColumn(label: Text('S')),
                  DataColumn(label: Text('Su')),
                  DataColumn(
                      label: Center(child: Text('                         M'))),
                  DataColumn(label: Text('Tu')),
                  DataColumn(label: Text('W')),
                ],
                rows: attendanceData.asMap().entries.map((data) {
                  int index = data.key;
                  final Color rowColor;
                  if (M[index].toString() == "Back from university") {
                    colorfont = int.parse("0xFF" "FFFFFF");
                    fontsize = 18;
                    rowColor = Color(tt);
                  } else if (index == 0) {
                    colorfont = int.parse("0xFF" "FFFFFF");
                    rowColor = Color(tt);
                  } else {
                    fontsize = 14;
                    colorfont = int.parse("0xFF" "000000");
                    if (index % 2 == 0) {
                      rowColor = Color(feild1);
                    } else {
                      rowColor = Color(feild2);
                    }
                  }
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return rowColor; // تحديد اللون
                      },
                    ),
                    cells: index == 0
                        ? [
                            DataCell(Text(
                              "",
                              style: TextStyle(color: Color(colorfont)),
                            )),
                            const DataCell(Text("")),
                            const DataCell(Text("")),
                            const DataCell(Center(
                              child: Text(
                                "Going to university",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            )),
                            const DataCell(Text("")),
                            const DataCell(Text("")),
                          ]
                        : [
                            DataCell(Text(
                              data.value['time'],
                              style: TextStyle(color: Color(colorfont)),
                            )),
                            DataCell(Text(S[index].toString())),
                            DataCell(Text(Su[index].toString())),
                            DataCell(Center(
                              child: Text(
                                M[index].toString(),
                                style: TextStyle(
                                    color: Color(colorfont),
                                    fontSize: fontsize),
                              ),
                            )),
                            DataCell(Text(Tu[index].toString())),
                            DataCell(Text(W[index].toString())),
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
