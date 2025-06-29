import 'package:flutter/material.dart';

class HalqaReportPage extends StatelessWidget {
  static final List<Map<String, dynamic>> halqatReportSample = [
    {
      "school_name": "مدرسة الفرقان لتحفيظ القرآن الكريم",
      "teacher_name": "الشيخ أحمد العتيبي",
      "halqa_name": "حلقة النور",
      "student_count": 12,
      "attendance_percentage": 92,
      "memorization_progress": 80,
      "notes": "الطلاب ملتزمون، ويوجد تحسن ملحوظ في الأداء."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> report = halqatReportSample.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير المدرسة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow("اسم المدرسة:", report['school_name']),
                buildRow("اسم الحلقة:", report['halqa_name']),
                buildRow("اسم المعلم:", report['teacher_name']),
                buildRow("عدد الطلاب:", report['student_count'].toString()),
                buildRow("نسبة الحضور:", "${report['attendance_percentage']}%"),
                buildRow("نسبة الإنجاز في الحفظ:",
                    "${report['memorization_progress']}%"),
                const SizedBox(height: 16),
                const Text(
                  "ملاحظات:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(report['notes']),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // ضع هنا استدعاء دالة الطباعة
          // مثال: PdfGenerator.generateReport();
        },
        label: const Text("طباعة"),
        icon: const Icon(Icons.print),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
