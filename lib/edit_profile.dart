import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/authenticationService.dart'; // ตรวจสอบ Path ให้ถูกต้อง

final Color primaryColor = const Color(0xFF203F9A);
final Color accentColor = const Color(0xFFE7A0CC);

class EditProfilePage extends StatefulWidget {
  final String? uid;
  final AuthenticationService authService;

  const EditProfilePage({
    super.key,
    required this.uid,
    required this.authService,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birth = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  List<String> selectedCategories = [];

  final List<String> interestsOptions = [
    'อาหารสุขภาพ',
    'อาหารทั่วไป',
    'ของหวาน',
    'เครื่องดื่ม',
    'อาหารฮาลาล',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.uid == null || widget.uid!.isEmpty) {
      print("🔥 Error: ไม่มี UID");
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPopupMessage('เกิดข้อผิดพลาด: ไม่พบข้อมูลผู้ใช้', isError: true);
        Navigator.of(context).pop();
      });
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        _name.text = data['name'] ?? '';
        _birth.text = data['birthdate'] ?? '';
        _weight.text = (data['weight'] ?? '0').toString();
        _height.text = (data['height'] ?? '0').toString();
        selectedCategories = List<String>.from(data['categories'] ?? []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    print("📝 เริ่มบันทึกข้อมูล...");

    if (widget.uid == null || widget.uid!.isEmpty) {
      print("❌ UID ว่าง");
      return;
    }

    if (!_formKey.currentState!.validate() || selectedCategories.isEmpty) {
      print("❌ ฟอร์มไม่สมบูรณ์");
      _showPopupMessage('กรุณากรอกข้อมูลให้ครบถ้วน', isError: true);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final dataToUpdate = {
      'name': _name.text.trim(),
      'birthdate': _birth.text,
      'weight': double.tryParse(_weight.text) ?? 0,
      'height': double.tryParse(_height.text) ?? 0,
      'categories': selectedCategories,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set(dataToUpdate, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context); // ปิด dialog
      Navigator.pop(context); // กลับหน้าโปรไฟล์
      _showPopupMessage('บันทึกข้อมูลสำเร็จ');
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context); // ปิด dialog
      _showPopupMessage('เกิดข้อผิดพลาด: $error', isError: true);
    }
  }

  void _showPopupMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildForm(),
    );
  }

  Widget buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'ชื่อ'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
            ),
            TextFormField(
              controller: _birth,
              decoration: const InputDecoration(
                labelText: 'วันเกิด',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _birth.text.isNotEmpty
                      ? DateTime.tryParse(_birth.text) ?? DateTime(2000)
                      : DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() => _birth.text =
                      pickedDate.toIso8601String().split('T').first);
                }
              },
            ),
            TextFormField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'น้ำหนัก (กก.)'),
              validator: (v) => (v == null ||
                      v.isEmpty ||
                      double.tryParse(v) == null)
                  ? 'กรุณากรอกน้ำหนักเป็นตัวเลข'
                  : null,
            ),
            TextFormField(
              controller: _height,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ส่วนสูง (ซม.)'),
              validator: (v) => (v == null ||
                      v.isEmpty ||
                      double.tryParse(v) == null)
                  ? 'กรุณากรอกส่วนสูงเป็นตัวเลข'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'ความสนใจ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interestsOptions.map((category) {
                final isSelected = selectedCategories.contains(category);
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: accentColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('บันทึกข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}
