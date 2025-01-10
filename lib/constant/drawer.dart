import 'package:app1/constant/color.dart';
import 'package:app1/screens/home.dart';
import 'package:flutter/material.dart';

import '../screens/profile.dart';

class CustomDrawer extends StatelessWidget {
  final String? username; // ชื่อผู้ใช้ที่จะแสดง
  final String? role;
  final Function()? onHomeTap; // Action สำหรับเมนู "หน้าหลัก"
  final Function()? onRepairListTap; // Action สำหรับเมนู "รายการแจ้งซ่อม"

  const CustomDrawer({
    Key? key,
    required this.username,
    required this.role,
    this.onHomeTap,
    this.onRepairListTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ส่วนหัว Drawer
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF547093), // สีพื้นหลัง
            ),
            child: SizedBox(
              width: double.infinity, // ขยายเต็มความกว้าง
              child: Padding(
                padding: EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80, // ขนาดของรูปโปรไฟล์
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // รูปแบบวงกลม
                        image: DecorationImage(
                          image: AssetImage('assets/img/runnerx.png'),
                          fit: BoxFit.cover, // ปรับรูปให้เต็มพื้นที่
                        ),
                        border: Border.all(
                          color: Colors.white, // ขอบสีขาว
                          width: 2, // ความหนาของขอบ
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      username ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      role ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ส่วนรายการเมนู
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.list, color: Colors.black87),
                  title: Text(
                    'รายการแจ้งซ่อม',
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Homepage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.black87),
                  title: Text(
                    'ข้อมูลส่วนตัว',
                    style: TextStyle(
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
