//======= ไฟล์ categorymenu.dart (ฉบับแก้ไขปัญหากะพริบและปรับปรุง UI) =======//
import 'package:flutter/material.dart';
import 'menu.dart' as menu;
import 'backend/showdialog.dart' as showdialog;
import 'about_us.dart';

// ==================== Theme Colors ====================
final Color primaryColor = const Color(0xFF203F9A);
final Color secondaryColor = const Color(0xFF4E7CB2);
final Color backgroundColor = const Color(0xFFEFE8E0);
final Color accentColor = const Color(0xFFE84797);
final Color highlightColor = const Color(0xFFE7A0CC);
final Color lightTextColor = const Color(0xFF4E7CB2);

class MenuCategoryPage extends StatefulWidget {
  final List<String> favoriteMenuIds;
  final Function(String) toggleFavorite;

  const MenuCategoryPage({
    super.key,
    required this.favoriteMenuIds,
    required this.toggleFavorite,
  });

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage> {
  // ✅ 1. สร้างตัวแปรเพื่อเก็บ stream ของเมนูไว้
  late final Stream<List<menu.MenuItem>> _menuStream;

  final Map<String, bool> _expanded = {
    "อาหารสุขภาพ": false,
    "อาหารเด็ก": false,
    "อาหารทั่วไป": false,
    "อาหารฮาลาล": false,
    "เครื่องดื่ม": false,
    "ของหวาน": false,
    "มังสวิรัติ": false,
  };

  final Map<String, IconData> categoryIcons = {
    "อาหารสุขภาพ": Icons.eco,
    "อาหารเด็ก": Icons.child_friendly,
    "อาหารทั่วไป": Icons.restaurant,
    "อาหารฮาลาล": Icons.mosque,
    "เครื่องดื่ม": Icons.local_drink,
    "ของหวาน": Icons.cake,
    "มังสวิรัติ": Icons.nature,
  };

  @override
  void initState() {
    super.initState();
    // ✅ 2. สั่งให้ stream ทำงานแค่ครั้งเดียวตอนที่หน้าถูกสร้างขึ้น
    _menuStream = menu.streamMenusFromFirebase();
  }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
        ],
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<menu.MenuItem>>(
        // ✅ 3. ใช้ตัวแปร stream ที่สร้างไว้ ไม่เรียกฟังก์ชันใหม่ทุกครั้ง
        stream: _menuStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ยังไม่มีเมนูอาหาร"));
          }

          final allMenus = snapshot.data!;

          final Map<String, List<menu.MenuItem>> categorizedMenus = {
            "อาหารสุขภาพ": allMenus
                .where((item) => item.category.contains("อาหารสุขภาพ"))
                .toList(),
            "อาหารเด็ก": allMenus
                .where((item) => item.category.contains("อาหารเด็ก"))
                .toList(),
            "อาหารทั่วไป": allMenus
                .where((item) => item.category.contains("อาหารทั่วไป"))
                .toList(),
            "อาหารฮาลาล": allMenus
                .where((item) => item.category.contains("อาหารฮาลาล"))
                .toList(),
            "เครื่องดื่ม": allMenus
                .where((item) => item.category.contains("เครื่องดื่ม"))
                .toList(),
            "ของหวาน": allMenus
                .where((item) => item.category.contains("ของหวาน"))
                .toList(),
            "มังสวิรัติ": allMenus
                .where((item) => item.category.contains("มังสวิรัติ"))
                .toList(),
          };

          return ListView(
            key: const PageStorageKey('categoryListView'),
            children: [
              _buildTopBanner(),
              _buildCategoryTitle(),
              const SizedBox(height: 10),
              ...categorizedMenus.entries.map((entry) {
                final categoryName = entry.key;
                final items = entry.value;
                if (items.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Card(
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: PageStorageKey<String>(categoryName),
                        title:
                            _buildExpansionTileTitle(categoryName, items.length),
                        initiallyExpanded: _expanded[categoryName] ?? false,
                        onExpansionChanged: (isOpen) {
                          setState(() {
                            _expanded[categoryName] = isOpen;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            child: GridView.builder(
                              key: PageStorageKey<String>('$categoryName:grid'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final menuItem = items[index];
                                final isFavorite = widget.favoriteMenuIds
                                    .contains(menuItem.id);
                                return _buildMenuItemCard(menuItem, isFavorite);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // --- Helper Widgets for Cleaner Build Method ---

  Widget _buildMenuItemCard(menu.MenuItem menuItem, bool isFavorite) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showdialog.showFullMenuDialog(
          context,
          menuItem,
          isFavorite,
          () => widget.toggleFavorite(menuItem.id),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMenuImage(menuItem.imagePath),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => widget.toggleFavorite(menuItem.id),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? accentColor : secondaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menuItem.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTileTitle(String categoryName, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: highlightColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categoryIcons[categoryName] ?? Icons.restaurant_menu,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: highlightColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [highlightColor, backgroundColor.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eat Healthy!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“Healthy food, happy mood.”',
                    style: TextStyle(
                      fontSize: 14,
                      color: lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.emoji_food_beverage_rounded,
                size: 40,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Food Category',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuImage(String imagePath) {
    return imagePath.startsWith("http")
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
  }
}

