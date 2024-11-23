import 'package:flutter/material.dart';

import '../color.dart';

class Detail extends StatelessWidget {
  final dynamic item; // ข้อมูลที่ส่งเข้ามา อาจเป็น Map หรือ Object

  const Detail({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
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
                _buildDetailRow('รหัสแจ้งซ่อม:', item['id'] ?? '-'),
                _buildDetailRow('ประเภท:', item['type'] ?? '-'),
                _buildDetailRow('รายละเอียด:', item['detail'] ?? '-'),
                _buildDetailRow('สถานะ:', item['status'] ?? '-'),
                _buildDetailRow('วันที่แจ้ง:', item['date'] ?? '-'),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('รับงาน',
                        style: TextStyle(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
}
