import 'package:al_furqan/controllers/HalagaController.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HalagaPlansScreen extends StatefulWidget {
  final HalagaModel halaga;

  const HalagaPlansScreen({Key? key, required this.halaga}) : super(key: key);

  @override
  _HalagaPlansScreenState createState() => _HalagaPlansScreenState();
}

class _HalagaPlansScreenState extends State<HalagaPlansScreen> {
  final _formKey = GlobalKey<FormState>();

  // قائمة المقررات الشرعية
  final List<String> islamicSubjects = [
    'التفسير',
    'الحديث',
    'الفقه',
    'السيرة النبوية',
    'القصص',
    'العقيدة',
    'الأخلاق',
  ];

  String? selectedIslamicSubject;

  // controllers للخطة الحفظ
  final TextEditingController conservationStartSurahController =
      TextEditingController();
  final TextEditingController conservationEndSurahController =
      TextEditingController();
  final TextEditingController conservationStartVerseController =
      TextEditingController();
  final TextEditingController conservationEndVerseController =
      TextEditingController();

  // controllers لخطة التلاوة
  final TextEditingController recitationStartSurahController =
      TextEditingController();
  final TextEditingController recitationEndSurahController =
      TextEditingController();
  final TextEditingController recitationStartVerseController =
      TextEditingController();
  final TextEditingController recitationEndVerseController =
      TextEditingController();

  // controllers للعلوم الشرعية
  final TextEditingController islamicStudiesContentController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    // تحميل خطة الحفظ إذا كانت موجودة
    if (widget.halaga.conservationStartSurah != null) {
      conservationStartSurahController.text =
          widget.halaga.conservationStartSurah!;
    }

    if (widget.halaga.conservationEndSurah != null) {
      conservationEndSurahController.text = widget.halaga.conservationEndSurah!;
    }

    if (widget.halaga.conservationStartVerse != null) {
      conservationStartVerseController.text =
          widget.halaga.conservationStartVerse.toString();
    }

    if (widget.halaga.conservationEndVerse != null) {
      conservationEndVerseController.text =
          widget.halaga.conservationEndVerse.toString();
    }

    // تحميل خطة التلاوة إذا كانت موجودة
    if (widget.halaga.recitationStartSurah != null) {
      recitationStartSurahController.text = widget.halaga.recitationStartSurah!;
    }

    if (widget.halaga.recitationEndSurah != null) {
      recitationEndSurahController.text = widget.halaga.recitationEndSurah!;
    }

    if (widget.halaga.recitationStartVerse != null) {
      recitationStartVerseController.text =
          widget.halaga.recitationStartVerse.toString();
    }

    if (widget.halaga.recitationEndVerse != null) {
      recitationEndVerseController.text =
          widget.halaga.recitationEndVerse.toString();
    }

    // تحميل العلوم الشرعية إذا كانت موجودة
    if (widget.halaga.islamicStudiesSubject != null) {
      selectedIslamicSubject = widget.halaga.islamicStudiesSubject;
    }

    if (widget.halaga.islamicStudiesContent != null) {
      islamicStudiesContentController.text =
          widget.halaga.islamicStudiesContent!;
    }
  }

  void _showAddSubjectDialog() {
    final TextEditingController newSubjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مقرر جديد'),
        content: TextField(
          controller: newSubjectController,
          decoration: InputDecoration(
            labelText: 'اسم المقرر',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newSubjectController.text.isNotEmpty) {
                setState(() {
                  islamicSubjects.add(newSubjectController.text);
                  selectedIslamicSubject = newSubjectController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlans() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحديث نموذج الحلقة بالخطط الجديدة
      HalagaModel updatedHalaga = widget.halaga;

      // خطة الحفظ
      updatedHalaga.conservationStartSurah =
          conservationStartSurahController.text;
      updatedHalaga.conservationEndSurah = conservationEndSurahController.text;
      updatedHalaga.conservationStartVerse =
          conservationStartVerseController.text.isEmpty
              ? null
              : int.tryParse(conservationStartVerseController.text);
      updatedHalaga.conservationEndVerse =
          conservationEndVerseController.text.isEmpty
              ? null
              : int.tryParse(conservationEndVerseController.text);

      // خطة التلاوة
      updatedHalaga.recitationStartSurah = recitationStartSurahController.text;
      updatedHalaga.recitationEndSurah = recitationEndSurahController.text;
      updatedHalaga.recitationStartVerse =
          recitationStartVerseController.text.isEmpty
              ? null
              : int.tryParse(recitationStartVerseController.text);
      updatedHalaga.recitationEndVerse =
          recitationEndVerseController.text.isEmpty
              ? null
              : int.tryParse(recitationEndVerseController.text);

      // العلوم الشرعية
      updatedHalaga.islamicStudiesSubject = selectedIslamicSubject;
      updatedHalaga.islamicStudiesContent =
          islamicStudiesContentController.text.isEmpty
              ? null
              : islamicStudiesContentController.text;

      // حفظ التغييرات
      await halagaController.updateHalagaPlans(updatedHalaga);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ الخطط بنجاح')),
      );

      Navigator.pop(context, true); // العودة مع إشارة إلى أن التغييرات تمت
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء حفظ الخطط: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطط الحلقة', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان الحلقة
              Text(
                'خطط حلقة: ${widget.halaga.Name ?? ""}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 24),

              // خطة الحفظ
              _buildCard(
                title: 'خطة الحفظ',
                icon: Icons.menu_book,
                child: Column(
                  children: [
                    _buildSubtitle('المخطط'),
                    _buildSurahInputRow(
                      label: 'من',
                      surahController: conservationStartSurahController,
                      verseController: conservationStartVerseController,
                      surahHint: 'سورة الرحمن',
                    ),
                    SizedBox(height: 10),
                    _buildSurahInputRow(
                      label: 'إلى',
                      surahController: conservationEndSurahController,
                      verseController: conservationEndVerseController,
                      surahHint: 'سورة الناس',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // خطة التلاوة
              _buildCard(
                title: 'خطة التلاوة',
                icon: Icons.record_voice_over,
                child: Column(
                  children: [
                    _buildSubtitle('المخطط'),
                    _buildSurahInputRow(
                      label: 'من',
                      surahController: recitationStartSurahController,
                      verseController: recitationStartVerseController,
                      surahHint: 'سورة الرحمن',
                    ),
                    SizedBox(height: 10),
                    _buildSurahInputRow(
                      label: 'إلى',
                      surahController: recitationEndSurahController,
                      verseController: recitationEndVerseController,
                      surahHint: 'سورة الأحقاف',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // العلوم الشرعية
              _buildCard(
                title: 'خطة العلوم الشرعية',
                icon: Icons.local_library,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // المقرر مع زر إضافة
                    Row(
                      children: [
                        Text(
                          'المقرر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('اختر المقرر'),
                                value: selectedIslamicSubject,
                                items: islamicSubjects.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedIslamicSubject = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: _showAddSubjectDialog,
                          icon: Icon(Icons.add_circle),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'إضافة مقرر جديد',
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // المحتوى المخطط
                    Text(
                      'المخطط',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: islamicStudiesContentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أدخل المحتوى المخطط للمقرر',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // عرض رسالة الخطأ إذا وجدت
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 24),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlans,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('حفظ الخطط', style: TextStyle(fontSize: 18)),
                ),
              ),

              // إشعار للمستخدم
              SizedBox(height: 16),
              Center(
                child: Text(
                  'يمكنك إدخال بيانات التنفيذ في صفحة تفاصيل الحلقة',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSurahInputRow({
    required String label,
    required TextEditingController surahController,
    required TextEditingController verseController,
    required String surahHint,
    bool isRequired = true,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: surahController,
            decoration: InputDecoration(
              hintText: surahHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            },
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: verseController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'آية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
