import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../constant/color.dart';
import 'home.dart';

class Detail extends StatefulWidget {
  final dynamic item; // ข้อมูลที่ส่งเข้ามา อาจเป็น Map หรือ Object

  const Detail({Key? key, required this.item}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? currentUserName; // ชื่อผู้ใช้งานที่ login
  String? currentStatus; // สถานะปัจจุบัน
  String? assignedTo; // ชื่อผู้รับงาน
  String? username;
  String? report_user_tel;
  String? assigned_to_tel;
  String? completedTime;
  String? location; // เพิ่มตัวแปรสำหรับสถานที่
  String? imageUrl; // เพิ่มตัวแปรเพื่อเก็บ URL ของรูปภาพ

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    fetchReportDetail(); // ดึงข้อมูลล่าสุดเมื่อเข้าใช้งาน
  }

  Future<void> _loadCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName =
          prefs.getString('name'); // ดึงชื่อจาก shared_preferences
    });
  }

  Future<void> fetchReportDetail() async {
    try {
      String url =
          "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/get_report_detail.php";
      final response = await http.post(
        Uri.parse(url),
        body: {'id': widget.item['id'].toString()}, // ส่ง ID เพื่อดึงข้อมูล
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = data['report']['status']; // อัปเดตสถานะ
          assignedTo = data['report']['assigned_to']; // อัปเดตชื่อผู้รับงาน
          username = data['report']['username']; // ดึงข้อมูล username
          location = data['report']['location']; // ดึงข้อมูล location
          report_user_tel = data['report']['report_user_tel'];
          assigned_to_tel = data['report']['assigned_to_tel'];
          completedTime =
              data['report']['completed_time']; // ดึงข้อมูล completed_time
          imageUrl = data['report']['image'] != null
              ? "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/image_view.php?filename=${data['report']['image']}"
              : null;

          print('Response JSON: $data');
          print('imageUrl: $imageUrl');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  // Future<void> _updateStatus(String newStatus) async {
  //   try {
  //     String url =
  //         "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/update_status.php";
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'id': widget.item['id'].toString(), // รหัสแจ้งซ่อม
  //         'status': newStatus, // สถานะใหม่
  //         'assigned_to': currentStatus == "รอดำเนินการ"
  //             ? currentUserName
  //             : assignedTo, // ใช้ assignedTo เดิมเมื่อสถานะเป็น "เสร็จสิ้น"
  //       },
  //     );

  //     var data = json.decode(response.body);

  //     if (data['status'] == "success") {
  //       setState(() {
  //         currentStatus = newStatus; // อัปเดตสถานะใน UI
  //         if (newStatus == "กำลังดำเนินการ") {
  //           assignedTo =
  //               currentUserName; // อัปเดต assignedTo ให้เป็นผู้ใช้งานปัจจุบัน
  //         }
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('สถานะถูกอัปเดตเรียบร้อย')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
  //     );
  //   }
  // }

  Future<List<dynamic>> allReport() async {
    var url = "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      String url =
          "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/update_status.php";

      // ถ้าสถานะเป็น "เสร็จสิ้น" ให้เก็บเวลาปัจจุบัน
      String? completedTime;
      if (newStatus == "เสร็จสิ้น") {
        DateTime now = DateTime.now();
        completedTime =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      }

      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': widget.item['id'].toString(),
          'status': newStatus,
          'assigned_to':
              currentStatus == "รอดำเนินการ" ? currentUserName : assignedTo,
          if (completedTime != null)
            'completed_time':
                completedTime, // ส่งค่าเวลาถ้าสถานะเป็น "เสร็จสิ้น"
        },
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = newStatus;
          if (newStatus == "กำลังดำเนินการ") {
            assignedTo = currentUserName;
          }
        });

        // 🔄 รีเฟรชข้อมูลใหม่
        fetchReportDetail();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สถานะถูกอัปเดตเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // ปิดปุ่มย้อนกลับอัตโนมัติ
        centerTitle: true,
        elevation: 0,
        backgroundColor: bottoncolor,
        title: const Text(
          'รายละเอียด',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: Font_.Fonts_T,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // ไปยังหน้า Homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Homepage(), // ไม่ต้องส่งชื่อผ่าน constructor
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('รหัสแจ้งซ่อม:', widget.item['id'] ?? '-'),
                _buildDetailRow(
                    'ผู้แจ้งซ่อม:', username ?? '-'), // ใช้ username
                _buildDetailRow('เบอร์โทรผู้แจ้งซ่อม:', report_user_tel ?? '-'),
                _buildDetailRow('ประเภท:', widget.item['type'] ?? '-'),
                _buildDetailRow('สถานที่', location ?? '-'), // แสดงสถานที่
                _buildDetailRow('รายละเอียด:', widget.item['detail'] ?? '-'),
                _buildDetailRow('สถานะ:', currentStatus ?? '-'),
                _buildDetailRow('วันที่แจ้ง:', widget.item['date'] ?? '-'),
                _buildDetailRow('เวลาที่แจ้งซ่อม:', widget.item['time'] ?? '-'),

                if (assignedTo != null && assignedTo!.isNotEmpty)
                  _buildDetailRow('ช่างซ่อม:', assignedTo ?? '-'),

                if (assignedTo != null && assignedTo!.isNotEmpty)
                  _buildDetailRow('เบอร์โทรช่างซ่อม', assigned_to_tel ?? '-'),

                if (completedTime != null && assignedTo!.isNotEmpty)
                  _buildDetailRow(
                      'วัน - เวลาที่เสร็จสิ้น', completedTime ?? '-'),
                const SizedBox(height: 20),

                if (imageUrl != null && imageUrl!.isNotEmpty)
                  _buildImage(), // แสดงภาพที่โหลดจาก URL

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.center,
                  child: currentStatus == "รอดำเนินการ"
                      ? _buildActionButton("รับงาน", "กำลังดำเนินการ")
                      : currentStatus == "กำลังดำเนินการ" &&
                              assignedTo == currentUserName
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildActionButton("เสร็จสิ้น", "เสร็จสิ้น"),
                                const SizedBox(width: 8), // ระยะห่างระหว่างปุ่ม
                                _buildActionButtonrepair(
                                    "ส่งซ่อมภายนอก", "ส่งซ่อมภายนอก"),
                              ],
                            )
                          : currentStatus == "ส่งซ่อมภายนอก" &&
                                  assignedTo == currentUserName
                              ? _buildActionButton("เสร็จสิ้น", "เสร็จสิ้น")
                              : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String newStatus) {
    return ElevatedButton.icon(
      onPressed: () => _updateStatus(newStatus),
      icon: const Icon(Icons.check, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
            fontFamily: Font_.Fonts_T,
            color: Colors.white,
            fontSize: 16,
          )),
      style: ElevatedButton.styleFrom(
        backgroundColor: bottoncolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildActionButtonrepair(String label, String newStatus) {
    return ElevatedButton.icon(
      onPressed: () => _updateStatus(newStatus),
      icon: const Icon(Icons.hardware, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
            fontFamily: Font_.Fonts_T,
            color: Colors.white,
            fontSize: 16,
          )),
      style: ElevatedButton.styleFrom(
        backgroundColor: bottoncolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
