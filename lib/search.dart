import 'package:flutter/material.dart';
import 'menu.dart' as menu;
import 'backend/showdialog.dart' as showdialog;
import 'backend/dataHelper.dart';
import 'about_us.dart';

// ==================== Theme Colors ====================
final Color primaryColor = Color(0xFF203F9A);
final Color secondaryColor = Color(0xFF4E7CB2);
final Color backgroundColor = Color(0xFFEFE8E0);
final Color accentColor = Color(0xFFE84797);
final Color lightTextColor = Color(0xFF4E7CB2);

// ==================== SearchPage ====================
class SearchPage extends StatefulWidget {
  final List<String> favoriteMenuIds;
  final Function(String) toggleFavorite;

  const SearchPage({
    super.key,
    required this.favoriteMenuIds,
    required this.toggleFavorite,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = "";
  late final Stream<List<menu.MenuItem>> _menuStream;

  @override
  void initState() {
    super.initState();
    _menuStream = DatabaseService().allMenusStream;
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
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<menu.MenuItem>>(
        stream: _menuStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ยังไม่มีเมนูอาหารในระบบ"));
          }

          final allMenus = snapshot.data!;
          final filteredMenus =
              query.isEmpty
                  ? <menu.MenuItem>[]
                  : allMenus
                      .where(
                        (menuItem) => menuItem.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                      )
                      .toList();

          return Column(
            children: [
              // --- Search Box ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "ค้นหาเมนูอาหาร...",
                    hintStyle: TextStyle(color: lightTextColor),
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),

              // --- Result ---
              Expanded(
                child:
                    filteredMenus.isEmpty && query.isNotEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 50,
                                color: lightTextColor,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "ไม่พบเมนู",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: lightTextColor,
                                ),
                              ),
                            ],
                          ),
                        )
                        : (query.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 50,
                                    color: lightTextColor,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "พิมพ์เพื่อค้นหาเมนูอาหาร...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredMenus.length,
                              itemBuilder: (context, index) {
                                final menuItem = filteredMenus[index];
                                final isFavorite = widget.favoriteMenuIds
                                    .contains(menuItem.id);

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          menuItem.imagePath.startsWith("http")
                                              ? NetworkImage(menuItem.imagePath)
                                              : AssetImage(menuItem.imagePath)
                                                  as ImageProvider,
                                    ),
                                    title: Text(
                                      menuItem.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isFavorite
                                                ? accentColor
                                                : secondaryColor,
                                      ),
                                      onPressed:
                                          () => widget.toggleFavorite(
                                            menuItem.id,
                                          ),
                                    ),
                                    onTap:
                                        () => showdialog.showFullMenuDialog(
                                          context,
                                          menuItem,
                                          isFavorite,
                                          () => widget.toggleFavorite(
                                            menuItem.id,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            )),
              ),
            ],
          );
        },
      ),
    );
  }
}
