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
  @override
  void initState() {
    super.initState();
    halagaController.gitData(widget.user.school_id as HalagaModel);
  }

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
            child: ListView.builder(
              itemCount: halaqat.length,
              itemBuilder: (context, index) {
                final halqa = halqat[index];
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
                        halqa['name']!,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المعلم: ${halqa['teacher']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          Text(
                            'الوقت: ${halqa['time']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing:
                          Icon(Icons.arrow_forward_ios, color: Colors.teal),
                      onTap: () {
                        // يمكن إضافة عملية الانتقال إلى صفحة تفاصيل الحلقة هنا
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          //   Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: SizedBox(
          //       width: double.infinity,
          //       child: ElevatedButton(
          //         onPressed: () {
          //           Navigator.pop(context);
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.red,
          //           padding: EdgeInsets.symmetric(vertical: 16),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //         ),
          //         child: Text(
          //           'رجوع',
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //     ),
          //   ),
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
