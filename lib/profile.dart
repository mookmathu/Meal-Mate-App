import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend/authenticationService.dart';
import 'login.dart';
import 'about_us.dart';
import 'edit_profile.dart'; // ✨ 1. เพิ่ม import สำหรับหน้า EditProfilePage
import 'package:shared_preferences/shared_preferences.dart';

final Color primaryColor = Color(0xFF203F9A);
final Color secondaryColor = Color(0xFF4E7CB2);
final Color backgroundColor = Color(0xFFEFE8E0);

class ProfilePage extends StatelessWidget {
  final AuthenticationService authService;

  const ProfilePage({super.key, required this.authService});

  Future<void> _logout(BuildContext context) async {
    try {
      await authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการออกจากระบบ: $e')),
        );
      }
    }
  }

  // ✨ 2. เพิ่มฟังก์ชันสำหรับนำทางไปหน้าแก้ไขโปรไฟล์
  void _navigateToEditProfile(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          uid: uid,
          authService: authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final uid = authSnapshot.data?.uid;

        if (uid == null) {
          // ... (ส่วนของโค้ดเมื่อยังไม่ล็อกอิน เหมือนเดิม)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "กรุณาเข้าสู่ระบบก่อน",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFE7A0CC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("เข้าสู่ระบบ"),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // ... (ส่วนของโค้ดเมื่อไม่พบข้อมูล เหมือนเดิม)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ไม่พบข้อมูลผู้ใช้",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text("ออกจากระบบ"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "MEAL MATE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                backgroundColor: primaryColor,
                elevation: 0,
                centerTitle: true,
                actions: [
                  // ✨ 3. เพิ่ม IconButton สำหรับปุ่ม Edit ที่นี่
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'แก้ไขโปรไฟล์',
                    onPressed: () => _navigateToEditProfile(context, uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.groups),
                    tooltip: 'About Us',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutUsPage()),
                      );
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    // ... (ส่วนแสดงผลข้อมูล Card และปุ่ม Logout เหมือนเดิม)
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFE7A0CC),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileItem('ชื่อ', data['name'] ?? '-', Icons.person_outline),
                            _buildProfileItem('อีเมล', data['email'] ?? '-', Icons.email_outlined),
                            _buildProfileItem('วันเกิด', data['birthdate'] ?? '-', Icons.cake_outlined),
                            _buildProfileItem('น้ำหนัก', '${data['weight'] ?? 0} กก.', Icons.balance),
                            _buildProfileItem('ส่วนสูง', '${data['height'] ?? 0} ซม.', Icons.height_outlined),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.favorite_border, color: Colors.blueAccent),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ความสนใจ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text(
                                        (data['categories'] as List<dynamic>?)?.join(', ') ?? '-',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text("ออกจากระบบ"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFE7A0CC),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}