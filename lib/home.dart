import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'backend/authenticationService.dart';
import 'menu.dart' as menu;
import 'myfav.dart';
import 'search.dart';
import 'profile.dart';
import 'categorymenu.dart';
import 'backend/showdialog.dart' as showdialog;
import 'backend/dataHelper.dart';
import 'about_us.dart';

// ==================== Theme Colors ====================
final Color primaryColor = Color(0xFF203F9A);
final Color secondaryColor = Color(0xFF4E7CB2);
final Color backgroundColor = Color(0xFFEFE8E0);
final Color accentColor = Color(0xFFE84797);
final Color lightTextColor = Color(0xFF4E7CB2);

// ==================== RealHomePage (ส่วนควบคุมหลัก) ====================
class RealHomePage extends StatefulWidget {
  const RealHomePage({super.key});

  @override
  State<RealHomePage> createState() => _RealHomePageState();
}

class _RealHomePageState extends State<RealHomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 2;

  // ✨ [แก้ไขสำคัญ] นี่คือจุดที่แก้ไขปัญหาทั้งหมด
  // เราจะประกาศตัวแปรไว้ก่อน แล้วค่อยกำหนดค่าใน initState
  late final User? currentUser;
  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลผู้ใช้ล่าสุด "เมื่อหน้านี้ถูกสร้างขึ้น" เสมอ
    // วิธีนี้ทำให้แอปอัปเดตข้อมูลตามผู้ใช้ที่ล็อกอินล่าสุด
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void toggleFavorite(String menuId) {
    if (currentUser != null) {
      DatabaseService(uid: currentUser!.uid).toggleFavoriteStatus(menuId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบเพื่อบันทึกเมนูโปรด')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: DatabaseService(uid: currentUser?.uid).favoriteMenuIdsStream,
      builder: (context, snapshot) {
        final favoriteMenuIds = snapshot.data ?? [];

        final List<Widget> pages = [
          SearchPage(
            favoriteMenuIds: favoriteMenuIds,
            toggleFavorite: toggleFavorite,
          ),
          MenuCategoryPage(
            favoriteMenuIds: favoriteMenuIds,
            toggleFavorite: toggleFavorite,
          ),
          HomeFoodPage(
            currentUser: currentUser,
            favoriteMenuIds: favoriteMenuIds,
            toggleFavorite: toggleFavorite,
          ),
          const FavoritePage(),
          ProfilePage(authService: _authService),
        ];

        return Scaffold(
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[_selectedIndex],
              transitionBuilder:
                  (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 10,
            color: Colors.white,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAnimatedTab(
                        icon: Icons.search,
                        label: "ค้นหา",
                        index: 0,
                      ),
                      _buildAnimatedTab(
                        icon: Icons.restaurant_menu,
                        label: "หมวดหมู่",
                        index: 1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildAnimatedTab(
                        icon: Icons.favorite,
                        label: "ชอบ",
                        index: 3,
                      ),
                      _buildAnimatedTab(
                        icon: Icons.person,
                        label: "โปรไฟล์",
                        index: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildAnimatedCenterButton(),
        );
      },
    );
  }

  Widget _buildAnimatedCenterButton() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.2 : 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (BuildContext context, double scale, Widget? child) {
          return Transform.translate(
            offset: Offset(0, isSelected ? -10 : 0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: isSelected ? 10 : 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.home, size: 35, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAnimatedTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: isSelected ? 1.2 : 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.translate(
            offset: Offset(0, isSelected ? -5 : 0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? lightTextColor.withOpacity(0.3)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? primaryColor : secondaryColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? primaryColor : secondaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HomeFoodPage (ส่วนแสดงผลหน้าแรก) ====================
// ... โค้ดส่วนนี้ไม่มีการเปลี่ยนแปลง ...
class HomeFoodPage extends StatelessWidget {
  final User? currentUser;
  final List<String> favoriteMenuIds;
  final Function(String) toggleFavorite;

  const HomeFoodPage({
    super.key,
    required this.currentUser,
    required this.favoriteMenuIds,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.groups, color: Colors.white),
            tooltip: 'About Us',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                ),
          ),
        ],
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<menu.MenuItem>>(
        stream: DatabaseService().allMenusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ยังไม่มีเมนูอาหาร"));
          }
          final allMenus = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingSection(),
                _buildRecommendationSection(context),
                _buildAllMenusSection(context, allMenus),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("เมนูแนะนำวันนี้ 🎲"),
        StreamBuilder<List<menu.MenuItem>>(
          stream: DatabaseService().getTodaysRecommendationStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 220,
                child: Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}")),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 220,
                child: Center(child: Text("ไม่มีเมนูในระบบ")),
              );
            }
            final randomMenus = snapshot.data!;
            return SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                scrollDirection: Axis.horizontal,
                itemCount: randomMenus.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildRecipeCard(context, randomMenus[index]),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'สวัสดีตอนเช้า ☀️';
    if (hour < 18) return 'สวัสดีตอนบ่าย 👋';
    return 'สวัสดีตอนเย็น 🌙';
  }

  Widget _buildGreetingSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'วันนี้อยากทำเมนูอะไรเป็นพิเศษไหม?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMenusSection(
    BuildContext context,
    List<menu.MenuItem> allMenus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("เมนูทั้งหมด"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allMenus.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return _buildRecipeCard(context, allMenus[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, menu.MenuItem menuItem) {
    final isFavorite = favoriteMenuIds.contains(menuItem.id);
    return GestureDetector(
      onTap:
          () => showdialog.showFullMenuDialog(
            context,
            menuItem,
            isFavorite,
            () => toggleFavorite(menuItem.id),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: _buildMenuImage(menuItem.imagePath),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              menuItem.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Text(
              menuItem.category.join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuImage(String imagePath) {
    bool isUrl = Uri.tryParse(imagePath)?.hasAbsolutePath ?? false;
    if (isUrl) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            (c, e, s) =>
                const Icon(Icons.broken_image_outlined, color: Colors.grey),
        loadingBuilder:
            (c, child, p) =>
                p == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            (c, e, s) =>
                const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );
    }
  }
}
