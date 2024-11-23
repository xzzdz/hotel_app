// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../color.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _obscurePassword = true; // กำหนดให้รหัสผ่านไม่แสดงเริ่มต้น

  Future sign_in() async {
    String url =
        "http://www.comdept.cmru.ac.th/64143168/hotel_app_php/login.php";
    final response = await http.post(Uri.parse(url), body: {
      'email': email.text,
      'password': password.text,
    });

    var data = json.decode(response.body);

    if (data['status'] == "Error") {
      // แสดงข้อความผิดพลาด
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text(data['message']), // ข้อความผิดพลาดจาก PHP
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (data['status'] == "success") {
      print("Name from API: ${data['name']}"); // ตรวจสอบค่าที่ได้จาก API
      // บันทึกชื่อผู้ใช้ลงใน shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', data['name']); // บันทึกค่าชื่อผู้ใช้

      // ไปยังหน้า Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const Homepage(), // ไม่ต้องส่งชื่อผ่าน constructor
        ),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => Homepage(),
      //   ),
      // );
    }
  }

  Future forgetpass() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot your password?'),
          content: Text('Please contact the admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('Comfirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      // const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลัง
      body: Center(
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/img/2.png',
                    width: 300,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'To continue using this app',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Please sign in first.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: TextFormField(
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        hintText: "E-mail",
                        hintStyle: TextStyle(
                          color: Colors.black12,
                          fontFamily: Font_.Fonts_T,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 251, 252, 244),
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your E-Mail';
                        }
                        return null;
                      },
                      controller: email,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: TextFormField(
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.key, color: Colors.black),
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.black12,
                          fontFamily: Font_.Fonts_T,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 251, 252, 244),
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color.fromARGB(255, 164, 164, 164),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword; // เปลี่ยนสถานะการแสดงรหัสผ่าน
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your Password';
                        }
                        return null;
                      },
                      controller: password,
                      obscureText:
                          _obscurePassword, // ใช้ตัวแปร _obscurePassword
                    ),
                  ),

                  // const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: TextButton(
                      onPressed: forgetpass,
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 120),
                    child: SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bottoncolor, // สีปุ่มเข้ม
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          bool valid = formKey.currentState!.validate();
                          if (valid) {
                            sign_in();
                          }
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
