import 'dart:ffi';

import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/views/SchoolDirector/AddHalaga.dart';
import 'package:flutter/material.dart';

class HalqatListPage extends StatefulWidget {
  final UserModel user;
  HalqatListPage({required this.user});

  @override
  State<HalqatListPage> createState() => _HalqatListPageState();
}

class _HalqatListPageState extends State<HalqatListPage> {
  // قائمة افتراضية تحتوي على بيانات الحلقات
  List<HalagaModel> halaqat = [];
  void initState() {
    super.initState();
    _loadHalaqat(); // استدعاء دالة جلب الحلقات عند تهيئة الصفحة
  }

  // دالة لجلب الحلقات من قاعدة البيانات
  void _loadHalaqat() async {
    List<HalagaModel> loadedHalaqat =
        await halagaController.gitData(widget.user.schoolID as HalagaModel);

    setState(() {
      halaqat = loadedHalaqat;
      // isLoading = false; // إخفاء مؤشر التحميل بعد جلب البيانات
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('الحلقات الدراسية',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: halaqat.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد حلقات مضافة.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: halaqat.length,
                    itemBuilder: (context, index) {
                      final halqa =
                          halaqat[index]; // الحصول على الحلقة بناءً على الفهرس
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.school, color: Colors.white),
                            ),
                            title: Text(
                              halqa.Name ?? 'اسم غير متوفر', // عرض اسم الحلقة
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المعلم: ${halqa.NumberStudent}', // عرض اسم المعلم
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                // Text(
                                //   'الوقت: ${halqa.time}', // عرض وقت الحلقة
                                //   style: TextStyle(
                                //       fontSize: 16, color: Colors.grey[600]),
                                // ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,
                                color: Colors.teal),
                            onTap: () {
                              // يمكن إضافة عملية الانتقال إلى صفحة تفاصيل الحلقة هنا
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // هنا يمكنك تنفيذ عملية الإضافة مثل الانتقال لصفحة إضافة حلقة جديدة
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddHalaqaScreen(user: widget.user)));
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
