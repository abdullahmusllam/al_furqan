import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  final TextEditingController absenceWithoutExcuseController = TextEditingController();
  final TextEditingController attendanceDaysController = TextEditingController();
  final TextEditingController absenceWithExcuseController = TextEditingController();
  final TextEditingController absenceReasonController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حضور المعلمين')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عدد أيام الدوام
            Center(
              child: Text(
                'عدد أيام الدوام: 25 يوم',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 20),

            // حقل عدد أيام الغياب بدون عذر
            _buildRowInput('أيام الغياب بدون عذر', absenceWithoutExcuseController),

            // حقل عدد أيام الحضور
            _buildRowInput('أيام الحضور', attendanceDaysController),

            // حقل عدد أيام الغياب بعذر
            _buildRowInput('أيام الغياب بعذر', absenceWithExcuseController),

            // حقل سبب الغياب
            _buildLargeTextField('أسباب الغياب', absenceReasonController),

            // حقل الملاحظات
            _buildLargeTextField('الملاحظات', notesController),

            SizedBox(height: 20),

            // زر حفظ البيانات
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // تنفيذ عملية حفظ البيانات
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blue,
                ),
                child: Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر إدخال صغير (رقمي)
  Widget _buildRowInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
          SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  // عنصر إدخال نصي كبير
  Widget _buildLargeTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
