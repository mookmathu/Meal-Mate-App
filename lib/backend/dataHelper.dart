// ignore: file_names
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../menu.dart'; 

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference menuCollection =
      FirebaseFirestore.instance.collection('meals');

  /// Stream สำหรับฟัง ID เมนูโปรด
  Stream<List<String>> get favoriteMenuIdsStream {
    if (uid == null) {
      return Stream.value([]);
    }
    return userCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['favoriteMenuIds'] ?? []);
    });
  }

  /// ✨ [แก้ไข] ฟังก์ชันสำหรับ เพิ่ม/ลบ เมนูโปรด ให้ทำงานได้จริง
  Future<void> toggleFavoriteStatus(String menuId) async {
    if (uid == null) return; // ถ้าไม่มี uid ให้หยุดทำงาน

    final userRef = userCollection.doc(uid);
    final userDoc = await userRef.get();

    // ตรวจสอบว่ามีเอกสาร user อยู่หรือไม่
    if (userDoc.exists) {
      List<String> favoriteIds = List<String>.from(
          (userDoc.data() as Map<String, dynamic>)['favoriteMenuIds'] ?? []);
      
      if (favoriteIds.contains(menuId)) {
        // ถ้ามีอยู่แล้ว ให้ลบออก
        await userRef.update({
          'favoriteMenuIds': FieldValue.arrayRemove([menuId])
        });
      } else {
        // ถ้ายังไม่มี ให้เพิ่มเข้าไป
        await userRef.update({
          'favoriteMenuIds': FieldValue.arrayUnion([menuId])
        });
      }
    } else {
      // กรณีที่ยังไม่มีเอกสาร user เลย (อาจเกิดจากข้อผิดพลาดตอนสมัคร)
      // ให้สร้างเอกสารใหม่พร้อมกับ field favoriteMenuIds
      await userRef.set({
        'favoriteMenuIds': [menuId]
      }, SetOptions(merge: true)); // merge:true เพื่อไม่ให้ข้อมูลอื่นถูกเขียนทับ
    }
  }

  /// ✨ [แก้ไข] ฟังก์ชันสำหรับดึง "เมนู" ที่ผู้ใช้กดถูกใจ
  Stream<List<MenuItem>> get favoriteMenusStream {
    if (uid == null) {
      return Stream.value([]);
    }
    return userCollection.doc(uid).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];

      final data = userDoc.data() as Map<String, dynamic>;
      List<String> favoriteIds = List<String>.from(data['favoriteMenuIds'] ?? []);

      if (favoriteIds.isEmpty) return [];

      List<MenuItem> favoriteMenus = [];
      for (int i = 0; i < favoriteIds.length; i += 10) {
        var chunk = favoriteIds.sublist(i, i + 10 > favoriteIds.length ? favoriteIds.length : i + 10);
        if (chunk.isNotEmpty) {
          final menuDocs = await menuCollection.where(FieldPath.documentId, whereIn: chunk).get();
          favoriteMenus.addAll(menuDocs.docs.map((doc) => MenuItem.fromFirestore(doc)));
        }
      }
      return favoriteMenus;
    });
  }
  
  Stream<List<MenuItem>> get allMenusStream {
      return menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  Stream<List<MenuItem>> getTodaysRecommendationStream() async* {
    try {
      final querySnapshot = await menuCollection.get();
      if (querySnapshot.docs.isEmpty) {
        yield [];
        return;
      }
      final allMenus = querySnapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
      allMenus.shuffle(Random());
      yield allMenus.take(10).toList();
    } catch (e) {
      print("Error getting random menus: $e");
      yield [];
    }
  }
}