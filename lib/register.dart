import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend/authenticationService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  List<String> selectedCategories = [];
  final List<String> categories = [
    'อาหารสุขภาพ',
    'อาหารทั่วไป',
    'ของหวาน',
    'เครื่องดื่ม',
    'อาหารฮาลาล',
  ];

  // ---------- Validators ----------
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกชื่อ';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  String? _validateBirthdate(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณาเลือกวันเกิด';
    return null;
  }

  String? _validateNumber(String? v, String field) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอก$field';
    final numVal = double.tryParse(v);
    if (numVal == null || numVal <= 0) return '$field ต้องเป็นตัวเลขมากกว่า 0';
    return null;
  }
  
  // ---------- [แก้ไข] ฟังก์ชันการลงทะเบียน ----------
  Future<void> _register() async {
    // 1. ตรวจสอบข้อมูลในฟอร์มก่อนเป็นอันดับแรก
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthenticationService();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // 2. ทำการสมัครสมาชิก (Authentication)
      final success = await authService.register(email, password);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลงทะเบียนล้มเหลว: อีเมลนี้อาจถูกใช้งานแล้ว')),
          );
        }
        return; // หยุดทำงานถ้าสมัครไม่สำเร็จ
      }

      // 3. เมื่อสมัครสำเร็จแล้ว ให้ดึง uid ของผู้ใช้ใหม่
      final uid = authService.getCurrentUser()?.uid;
      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เกิดข้อผิดพลาด: ไม่พบรหัสผู้ใช้')),
          );
        }
        return; // หยุดทำงานถ้าไม่เจอ uid
      }

      // 4. บันทึกข้อมูลทั้งหมดลง Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': email,
        'birthdate': birthdateController.text,
        'weight': double.tryParse(weightController.text) ?? 0,
        'height': double.tryParse(heightController.text) ?? 0,
        'categories': selectedCategories,
        'favoriteMenuIds': [], // ✨ เพิ่ม field นี้เข้าไป
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ลงทะเบียนสำเร็จ')));
      
      // กลับไปหน้าก่อนหน้าหลังลงทะเบียนสำเร็จ
      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ', border: OutlineInputBorder()),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'อีเมล', border: OutlineInputBorder()),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: birthdateController,
                readOnly: true,
                validator: _validateBirthdate,
                decoration: const InputDecoration(
                  labelText: 'วันเกิด',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      birthdateController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'น้ำหนัก (กก.)', border: OutlineInputBorder()),
                validator: (v) => _validateNumber(v, 'น้ำหนัก'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ส่วนสูง (ซม.)', border: OutlineInputBorder()),
                validator: (v) => _validateNumber(v, 'ส่วนสูง'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ความสนใจในอาหาร:'),
                    ...categories.map((cat) {
                      return CheckboxListTile(
                        title: Text(cat),
                        value: selectedCategories.contains(cat),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedCategories.add(cat);
                            } else {
                              selectedCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('สมัครสมาชิก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}