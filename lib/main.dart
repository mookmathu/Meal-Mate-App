import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend/firebase_options.dart';
import 'page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend/menucollection.dart';

// ==================== Theme Colors ====================
final Color primaryColor = Color(0xFF203F9A);
final Color secondaryColor = Color(0xFF4E7CB2);
final Color backgroundColor = Color(0xFFEFE8E0);
final Color accentColor = Color(0xFFE84797);
final Color highlightColor = Color(0xFFE7A0CC);
final Color lightTextColor = Color(0xFF4E7CB2);


// ✨ [โค้ดใหม่] ฟังก์ชันซิงค์ข้อมูลเมนู (สร้างใหม่หรืออัปเดตทับ)
Future<void> syncMenusToFirebase() async {
  final CollectionReference mealsCollection = FirebaseFirestore.instance.collection('meals');
  print("🚀 เริ่มต้นการซิงค์ข้อมูลเมนู...");

  for (var menu in menuData) {
    // ใช้ชื่อเมนูเป็น ID ของเอกสาร
    final docRef = mealsCollection.doc(menu['name']);
    
    try {
      // .set() จะสร้างเอกสารใหม่หากยังไม่มี ID นี้ 
      // หรือจะเขียนทับข้อมูลเก่าทั้งหมดหากมี ID นี้อยู่แล้ว
      // ทำให้ข้อมูลใน Firebase ตรงกับ menuData ในโค้ดเสมอ
      await docRef.set(menu);
      print("✅ ซิงค์เมนู '${menu['name']}' สำเร็จ");
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการซิงค์ '${menu['name']}': $e");
    }
  }
  print("🏁 การซิงค์เมนูเสร็จสิ้น");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ✨ [แก้ไข] เรียกใช้ฟังก์ชันนี้เพื่อสร้างหรืออัปเดตเมนูทั้งหมด
  // หลังจากรันครั้งแรกจนข้อมูลเข้า Firebase แล้ว สามารถคอมเมนต์บรรทัดนี้ไว้ได้
  await syncMenusToFirebase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Mate App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: secondaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: lightTextColor),
          bodyMedium: TextStyle(color: lightTextColor),
        ),
      ),
      home: const CoverPage(),
    );
  }
}