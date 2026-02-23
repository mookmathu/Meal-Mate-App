import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'menu.dart';
import 'backend/showdialog.dart' as showdialog;
import 'backend/dataHelper.dart';
import 'about_us.dart';

// ==================== Theme Colors ====================
final Color primaryColor = Color(0xFF203F9A);
final Color secondaryColor = Color(0xFF4E7CB2);
final Color backgroundColor = Color(0xFFEFE8E0);
final Color accentColor = Color(0xFFE84797);
final Color highlightColor = Color(0xFFE7A0CC);

// ==================== FavoritePage ====================
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late final User? currentUser;
  late final DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _dbService = DatabaseService(uid: currentUser?.uid);
  }

  void toggleFavorite(String menuId) {
    _dbService.toggleFavoriteStatus(menuId);
  }

  // ✨ [เพิ่มเข้ามาใหม่] ฟังก์ชันสำหรับแสดง SnackBar พร้อมปุ่ม "ยกเลิก"
  void _showUndoSnackBar(MenuItem menuItem) {
    // ซ่อน SnackBar เก่า (ถ้ามี) ก่อนแสดงอันใหม่
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${menuItem.name}' ถูกลบออกจากเมนูโปรด"),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ยกเลิก',
          onPressed: () {
            // เมื่อกดยกเลิก ให้เพิ่มเมนูกลับเข้าไปใหม่
            toggleFavorite(menuItem.id);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MEAL MATE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups, color: Colors.white),
            tooltip: 'About Us',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage())),
          ),
        ],
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (currentUser == null) {
      return Center(
        child: Text("กรุณาเข้าสู่ระบบเพื่อดูเมนูโปรด", style: TextStyle(fontSize: 18, color: primaryColor)),
      );
    }

    return StreamBuilder<List<MenuItem>>(
      stream: _dbService.favoriteMenusStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text("ยังไม่มีเมนูโปรด", style: TextStyle(fontSize: 18, color: primaryColor)),
                const SizedBox(height: 8),
                Text("ลองกด ❤️ ที่เมนูที่คุณชอบดูสิ", style: TextStyle(fontSize: 14, color: secondaryColor)),
              ],
            ),
          );
        }

        final favoriteMenus = snapshot.data!;

        return ListView(
          children: [
            _buildTopBanner(favoriteMenus.length),
            const SizedBox(height: 10),
            // ✨ [แก้ไข] เปลี่ยนมาใช้ ListView.builder เพื่อประสิทธิภาพที่ดีขึ้น
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriteMenus.length,
              itemBuilder: (context, index) {
                final menu = favoriteMenus[index];

                // ✨ [แก้ไข] ห่อ Card ด้วย Dismissible Widget
                return Dismissible(
                  // Key ที่ไม่ซ้ำกันสำหรับแต่ละรายการ
                  key: Key(menu.id),
                  
                  // ทิศทางการเลื่อน (จากขวาไปซ้าย)
                  direction: DismissDirection.endToStart,
                  
                  // สิ่งที่เกิดขึ้น "หลังจาก" เลื่อนจนสุดแล้ว
                  onDismissed: (direction) {
                    // 1. ลบเมนูออกจากรายการโปรด
                    toggleFavorite(menu.id);
                    // 2. แสดง SnackBar พร้อมปุ่มยกเลิก
                    _showUndoSnackBar(menu);
                  },

                  // UI ที่จะแสดงเป็นพื้นหลัง "ขณะที่" กำลังเลื่อน
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete_sweep,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Widget ที่จะแสดงผลปกติ (Card ของเรา)
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite),
                        color: accentColor,
                        onPressed: () => toggleFavorite(menu.id),
                        tooltip: 'ลบจากเมนูโปรด',
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: menu.imagePath.startsWith("http")
                            ? NetworkImage(menu.imagePath)
                            : AssetImage(menu.imagePath) as ImageProvider,
                      ),
                      title: Text(menu.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                      subtitle: Text("กดเพื่อดูสูตร", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: secondaryColor)),
                      onTap: () => showdialog.showFullMenuDialog(context, menu, true, () => toggleFavorite(menu.id)),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTopBanner(int favoriteCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [highlightColor, accentColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [ BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)) ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('เมนูโปรดของคุณ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('คุณมีเมนูที่ถูกใจทั้งหมด $favoriteCount รายการ', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(40)),
              child: Icon(Icons.favorite, size: 40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}