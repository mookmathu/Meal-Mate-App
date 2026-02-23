import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import '../login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ StreamBuilder เพื่อ "ฟัง" การเปลี่ยนแปลงสถานะการล็อกอินตลอดเวลา
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ขณะกำลังรอเช็คข้อมูล
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ถ้า Stream มีข้อมูล user (แปลว่าล็อกอินสำเร็จแล้ว)
        if (snapshot.hasData) {
          return const RealHomePage(); // ไปยังหน้า Home
        }
        
        // ถ้าไม่มีข้อมูล (แปลว่ายังไม่ได้ล็อกอิน หรือ logout ไปแล้ว)
        else {
          return const LoginScreen(); // ไปยังหน้า Login
        }
      },
    );
  }
}