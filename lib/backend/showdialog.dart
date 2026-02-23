import 'package:flutter/material.dart';
import '../menu.dart';

// --- Theme Colors ---
final Color primaryColor = const Color(0xFF203F9A);
final Color backgroundColor = const Color(0xFFEFE8E0);
final Color accentColor = const Color(0xFFE84797);

// --- Helper function for building image widget ---
Widget _buildMenuImage(String imagePath) {
  return imagePath.startsWith("http")
      ? Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.white),
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

/// --- Main function to show the dialog ---
void showFullMenuDialog(
  BuildContext context,
  MenuItem menuItem,
  bool isFavorite,
  VoidCallback onFavoritePressed,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
          child: _MenuDialogContent(
            menuItem: menuItem,
            initialIsFavorite: isFavorite,
            onFavoritePressed: onFavoritePressed,
          ),
        ),
      );
    },
  );
}

/// --- StatefulWidget to manage the dialog's internal state ---
class _MenuDialogContent extends StatefulWidget {
  final MenuItem menuItem;
  final bool initialIsFavorite;
  final VoidCallback onFavoritePressed;

  const _MenuDialogContent({
    required this.menuItem,
    required this.initialIsFavorite,
    required this.onFavoritePressed,
  });

  @override
  State<_MenuDialogContent> createState() => _MenuDialogContentState();
}

class _MenuDialogContentState extends State<_MenuDialogContent> {
  late bool isCurrentlyFavorite;

  @override
  void initState() {
    super.initState();
    isCurrentlyFavorite = widget.initialIsFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // --- Image Section ---
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMenuImage(widget.menuItem.imagePath),
                  Container(color: Colors.black.withOpacity(0.2)),
                  // --- Close Button ---
                  Positioned(
                    left: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                  // --- Favorite Button ---
                  Positioned(
                    right: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () {
                        widget.onFavoritePressed();
                        setState(() {
                          isCurrentlyFavorite = !isCurrentlyFavorite;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        child: Icon(
                          isCurrentlyFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isCurrentlyFavorite
                              ? accentColor
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- Details Section ---
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menuItem.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "วัตถุดิบ",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.menuItem.ingredients.join(", "),
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "วิธีทำ",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.menuItem.steps
                          .asMap()
                          .entries
                          .map((e) => "${e.key + 1}. ${e.value}")
                          .join("\n\n"),
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
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
}

