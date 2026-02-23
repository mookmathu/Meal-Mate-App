import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String imagePath;
  final List<String> category;

  MenuItem({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.imagePath,
    required this.category,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuItem( 
      id: doc.id,
      name: data['name'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      imagePath: data['imagePath'] ?? '',
      category: List<String>.from(data['category'] ?? []),
    );
  }
}

// ✅ Stream ใช้สำหรับดึงข้อมูลแบบเรียลไทม์ (ควรย้ายไป database_service แต่ไว้ที่นี่ก่อนได้)
Stream<List<MenuItem>> streamMenusFromFirebase() {
  return FirebaseFirestore.instance
      .collection('meals')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList());
}