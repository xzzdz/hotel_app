import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color.dart';
import '../constant/drawer.dart';
import 'login.dart';

class Nonti extends StatefulWidget {
  const Nonti({super.key});

  @override
  State<Nonti> createState() => _NontiState();
}

class _NontiState extends State<Nonti> {
  String? uesrname;
  String? role;

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uesrname = prefs.getString('name'); // ดึงค่าชื่อผู้ใช้
      role = prefs.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName(); // โหลดข้อมูลก่อนแสดงผล
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
          "การแจ้งเตือน",
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
      body: const Center(
        child: Text(
          'ยังไม่มีการแจ้งซ่อม',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: Font_.Fonts_T,
            color: Colors.black54,
          ),
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
