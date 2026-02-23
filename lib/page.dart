import 'package:flutter/material.dart';
import 'sharestorage/auth_gate.dart'; 

class CoverPage extends StatefulWidget {
  const CoverPage({super.key});

  @override
  State<CoverPage> createState() => _CoverPageState();
}

class _CoverPageState extends State<CoverPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    // ตั้งเวลา 3 วินาทีเพื่อแสดงหน้าปก
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // ✨ หลังจากแสดงหน้าปกเสร็จ ให้ส่งต่อไปที่ AuthGate ที่ถูกต้อง
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/MEALMATE.jpg', 
              fit: BoxFit.cover,
            ),
            const Positioned(
              bottom: 50, left: 0, right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}