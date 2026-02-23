//======= ไฟล์ authenticationService.dart เอาไว้ทำ Authentication ใน Firebase =======

import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔑 เข้าสู่ระบบด้วยอีเมล/รหัสผ่าน
  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  /// 📝 ลงทะเบียนผู้ใช้ใหม่
  Future<bool> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  /// 🚪 ออกจากระบบ
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Logout error: $e");
    }
  }

  /// 👤 ดึง user ปัจจุบัน (null = ไม่มีคน login อยู่)
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// ✅ ตรวจสอบว่ามี user login อยู่หรือไม่
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// 🔄 ใช้สำหรับฟัง event ว่ามี user login/logout
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
  // existing methods and properties

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      rethrow;
    }
  }
}