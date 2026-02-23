import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- ส่วนจัดการการล็อกอิน ---

  /// ฟังก์ชันล็อกอิน: จัดการทั้ง Firebase และบันทึกสถานะในเครื่อง
  Future<bool> login(String email, String password) async {
    try {
      // 1. พยายามล็อกอินกับ Firebase
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // 2. ถ้าล็อกอินสำเร็จ ให้บันทึกสถานะทันที
      await _saveLoginState();
      
      return true; // คืนค่าว่าสำเร็จ
    } catch (e) {
      print("Login Error: $e");
      return false; // คืนค่าว่าล้มเหลว
    }
  }

  /// ฟังก์ชันล็อกเอาท์: จัดการทั้ง Firebase และลบสถานะในเครื่อง
  Future<void> logout() async {
    await _auth.signOut();
    await _clearLoginState();
  }

  // --- ส่วนจัดการ SharedPreferences ---

  /// ตรวจสอบสถานะล็อกอินตอนเปิดแอป (สำหรับ AuthGate)
  Future<bool> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// (private) บันทึกสถานะลงเครื่อง
  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  /// (private) ลบสถานะออกจากเครื่อง
  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }
}