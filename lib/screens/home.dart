import 'dart:convert';
import 'package:app1/screens/detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // เพิ่ม import สำหรับ Timer

import '../constant/color.dart';
import '../constant/drawer.dart';
import 'login.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    Key? key,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? uesrname;
  String? role;
  String? selectedType = 'ทั้งหมด';
  String? selectedStatus = 'ทั้งหมด';
  int currentPage = 1;
  final int itemsPerPage = 5;

  List<String> types = ['ทั้งหมด', 'ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = [
    'ทั้งหมด',
    'รอดำเนินการ',
    'กำลังดำเนินการ',
    'เสร็จสิ้น'
  ];

  List<dynamic> reports = [];
  List<dynamic> previousReports = []; // เก็บข้อมูล reports ก่อนหน้า
  Timer? pollingTimer; // ตัวแปรสำหรับ Timer

  Future<List<dynamic>> allReport() async {
    var url = "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "รอดำเนินการ":
        return Icons.hourglass_empty;
      case "กำลังดำเนินการ":
        return Icons.autorenew;
      default:
        return Icons.check_circle; // ไอคอนสําหรับสถานะ "เสร็จสิ้น"
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "รอดำเนินการ":
        return Colors.red[300]!;
      case "กำลังดำเนินการ":
        return Colors.orange[300]!;
      default:
        return Colors.green[300]!;
    }
  }

  void goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uesrname = prefs.getString('name'); // ดึงค่าชื่อผู้ใช้
      role = prefs.getString('role');
    });
  }

  void startPolling() {
    // สร้าง Timer เพื่อดึงข้อมูลซ้ำ ๆ
    pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchReports();
    });
    fetchReports(); // ดึงข้อมูลทันทีเมื่อเริ่มต้น
  }

  Future<void> fetchReports() async {
    try {
      List<dynamic> newReports = await allReport();

      // ตรวจสอบว่ามีรายการใหม่จริง ๆ หรือไม่
      bool hasNewReport = newReports.length > previousReports.length;

      if (hasNewReport) {
        // แสดง SnackBar เฉพาะเมื่อมีรายการใหม่
        if (previousReports.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('มีรายการแจ้งซ่อมใหม่!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
        // อัปเดตข้อมูล reports และ previousReports
        setState(() {
          reports = newReports;
          previousReports = List.from(newReports); // คัดลอกข้อมูลใหม่ไปเก็บ
        });
      }
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName(); // โหลดข้อมูลก่อนแสดงผล
    startPolling(); // เริ่มต้นการดึงข้อมูลแบบ Periodic Polling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        username: uesrname, // ส่งค่าชื่อผู้ใช้ไปยัง CustomDrawer
        role: role,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false, // ไม่แสดงปุ่ม back
        backgroundColor: bottoncolor,
        title: const Text(
          "ระบบแจ้งซ่อม ",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: Font_.Fonts_T,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'ออกจากระบบ',
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "ค้นหารายการแจ้งซ่อม",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: Font_.Fonts_T,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: "เลือกประเภท",
                      labelStyle: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: "เลือกสถานะ",
                      labelStyle: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: statuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 8,
              child: FutureBuilder<List<dynamic>>(
                future: allReport(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล",
                          style: TextStyle(fontFamily: Font_.Fonts_T)),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredData = snapshot.data!.where((item) {
                    return (selectedType == 'ทั้งหมด' ||
                            item['type'] == selectedType) &&
                        (selectedStatus == 'ทั้งหมด' ||
                            item['status'] == selectedStatus);
                  }).toList();

                  final pageCount = (filteredData.length / itemsPerPage).ceil();
                  final startIndex = (currentPage - 1) * itemsPerPage;
                  final endIndex =
                      (startIndex + itemsPerPage) < filteredData.length
                          ? startIndex + itemsPerPage
                          : filteredData.length;
                  final paginatedData =
                      filteredData.sublist(startIndex, endIndex);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "รายการแจ้งซ่อมล่าสุด ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                              color: Color(0xFF37474F),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: currentPage > 1
                                    ? () {
                                        goToPage(currentPage - 1);
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: currentPage < pageCount
                                    ? () {
                                        goToPage(currentPage + 1);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: paginatedData.length,
                          itemBuilder: (context, index) {
                            final item = paginatedData[index];
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.date_range,
                                                color: Color(0xFF3A506B)),
                                            const SizedBox(width: 5),
                                            Text(
                                              "วันที่: ${item['date']}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: Font_.Fonts_T,
                                                color: Color(0xFF3A506B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                getStatusColor(item['status']),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  getStatusIcon(item['status']),
                                                  color: Colors.white),
                                              const SizedBox(width: 5),
                                              Text(
                                                item['status'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.build,
                                            color: Color(0xFF3A506B)),
                                        const SizedBox(width: 5),
                                        Text(
                                          "ประเภท: ${item['type']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.description,
                                            color: Colors.grey),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            "รายละเอียด: ${item['detail']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: Font_.Fonts_T,
                                              color: Color.fromARGB(
                                                  255, 73, 72, 72),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Detail(
                                                item: item,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.info,
                                            color: Colors.white),
                                        label: const Text(
                                          'ดูรายละเอียด',
                                          style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 84, 112, 147),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // ปิด dialog ก่อน
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs
                    .clear(); // ลบข้อมูลทั้งหมด หรือใช้ prefs.remove('name') เพื่อลบเฉพาะค่า
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              },
              child: Text('confirm'),
            ),
          ],
        );
      },
    );
  }
}
