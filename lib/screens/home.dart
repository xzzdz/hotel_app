import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../color.dart';
import 'login.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? selectedType = 'ทั้งหมด';
  String? selectedStatus = 'ทั้งหมด';

  List<String> types = ['ทั้งหมด', 'ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = [
    'ทั้งหมด',
    'รอดำเนินการ',
    'กำลังดำเนินการ',
    'เสร็จสิ้น'
  ];

  // Future logout() async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const Login(),
  //     ),
  //   );
  // }
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
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog ก่อน
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

  Future<List<dynamic>> allReport() async {
    var url = "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    // ตรวจสอบว่าการตอบสนองจากเซิร์ฟเวอร์สำเร็จหรือไม่
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
        return Icons.check_circle; //เสร็จสิ้น
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: bottoncolor,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.build, color: Colors.white),
            SizedBox(width: 16),
            Text(
              "ระบบแจ้งซ่อม",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: Font_.Fonts_T,
                color: Colors.white,
              ),
            ),
          ],
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
            const Text(
              "รายการแจ้งซ่อมล่าสุด",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: Font_.Fonts_T,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
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

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
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
                                      color: getStatusColor(item['status']),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(getStatusIcon(item['status']),
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
                                        color: Color.fromARGB(255, 73, 72, 72),
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
                                    // ดูรายละเอียดเพิ่มเติม
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
                                    backgroundColor:
                                        const Color.fromARGB(255, 84, 112, 147),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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