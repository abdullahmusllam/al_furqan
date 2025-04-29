import 'package:flutter/material.dart';
import 'package:al_furqan/controllers/StudentPlansController.dart';
import 'package:al_furqan/models/student_plan_model.dart';
import 'package:intl/intl.dart';

class StudentPlanDetailScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  final int halagaId;
  final StudentPlanModel? plan;

  const StudentPlanDetailScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.halagaId,
    this.plan,
  }) : super(key: key);

  @override
  _StudentPlanDetailScreenState createState() =>
      _StudentPlanDetailScreenState();
}

class _StudentPlanDetailScreenState extends State<StudentPlanDetailScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;

  // نموذج الخطة
  late StudentPlanModel _planModel;

  // قائمة السور
  final List<String> surahs = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس'
  ];

  // للحفظ
  final conservationStartSurahController = TextEditingController();
  final conservationEndSurahController = TextEditingController();
  final conservationStartVerseController = TextEditingController();
  final conservationEndVerseController = TextEditingController();

  // للمنفذ من الحفظ
  final executedConservationStartSurahController = TextEditingController();
  final executedConservationEndSurahController = TextEditingController();
  final executedConservationStartVerseController = TextEditingController();
  final executedConservationEndVerseController = TextEditingController();

  // للتلاوة
  final recitationStartSurahController = TextEditingController();
  final recitationEndSurahController = TextEditingController();
  final recitationStartVerseController = TextEditingController();
  final recitationEndVerseController = TextEditingController();

  // للمنفذ من التلاوة
  final executedRecitationStartSurahController = TextEditingController();
  final executedRecitationEndSurahController = TextEditingController();
  final executedRecitationStartVerseController = TextEditingController();
  final executedRecitationEndVerseController = TextEditingController();

  // للملاحظات
  final teacherNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // تهيئة نموذج الخطة
    _initPlanModel();
  }

  void _initPlanModel() {
    // إذا كانت الخطة موجودة، نستخدمها، وإلا ننشئ خطة جديدة
    _planModel = widget.plan ??
        StudentPlanModel(
          studentId: widget.studentId,
          halagaId: widget.halagaId,
          lastUpdated: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        );

    // تعبئة حقول النموذج من البيانات
    _fillFormFields();
  }

  void _fillFormFields() {
    // الحفظ
    conservationStartSurahController.text =
        _planModel.conservationStartSurah ?? '';
    conservationEndSurahController.text = _planModel.conservationEndSurah ?? '';
    conservationStartVerseController.text =
        _planModel.conservationStartVerse?.toString() ?? '';
    conservationEndVerseController.text =
        _planModel.conservationEndVerse?.toString() ?? '';

    // المنفذ من الحفظ
    executedConservationStartSurahController.text =
        _planModel.executedConservationStartSurah ?? '';
    executedConservationEndSurahController.text =
        _planModel.executedConservationEndSurah ?? '';
    executedConservationStartVerseController.text =
        _planModel.executedConservationStartVerse?.toString() ?? '';
    executedConservationEndVerseController.text =
        _planModel.executedConservationEndVerse?.toString() ?? '';

    // التلاوة
    recitationStartSurahController.text = _planModel.recitationStartSurah ?? '';
    recitationEndSurahController.text = _planModel.recitationEndSurah ?? '';
    recitationStartVerseController.text =
        _planModel.recitationStartVerse?.toString() ?? '';
    recitationEndVerseController.text =
        _planModel.recitationEndVerse?.toString() ?? '';

    // المنفذ من التلاوة
    executedRecitationStartSurahController.text =
        _planModel.executedRecitationStartSurah ?? '';
    executedRecitationEndSurahController.text =
        _planModel.executedRecitationEndSurah ?? '';
    executedRecitationStartVerseController.text =
        _planModel.executedRecitationStartVerse?.toString() ?? '';
    executedRecitationEndVerseController.text =
        _planModel.executedRecitationEndVerse?.toString() ?? '';

    // الملاحظات
    teacherNotesController.text = _planModel.teacherNotes ?? '';
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحديث نموذج الخطة من الحقول
      _updatePlanModelFromFields();

      // حفظ الخطة
      bool success = await studentPlansController.saveStudentPlan(_planModel);

      if (!success) {
        throw Exception("فشل في حفظ خطة الطالب");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ خطة الطالب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // العودة مع إشارة للتحديث
      }
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء حفظ الخطة: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updatePlanModelFromFields() {
    // تحديث الحفظ
    _planModel.conservationStartSurah =
        conservationStartSurahController.text.isEmpty
            ? null
            : conservationStartSurahController.text;
    _planModel.conservationEndSurah =
        conservationEndSurahController.text.isEmpty
            ? null
            : conservationEndSurahController.text;
    _planModel.conservationStartVerse =
        conservationStartVerseController.text.isEmpty
            ? null
            : int.tryParse(conservationStartVerseController.text);
    _planModel.conservationEndVerse =
        conservationEndVerseController.text.isEmpty
            ? null
            : int.tryParse(conservationEndVerseController.text);

    // تحديث المنفذ من الحفظ
    _planModel.executedConservationStartSurah =
        executedConservationStartSurahController.text.isEmpty
            ? null
            : executedConservationStartSurahController.text;
    _planModel.executedConservationEndSurah =
        executedConservationEndSurahController.text.isEmpty
            ? null
            : executedConservationEndSurahController.text;
    _planModel.executedConservationStartVerse =
        executedConservationStartVerseController.text.isEmpty
            ? null
            : int.tryParse(executedConservationStartVerseController.text);
    _planModel.executedConservationEndVerse =
        executedConservationEndVerseController.text.isEmpty
            ? null
            : int.tryParse(executedConservationEndVerseController.text);

    // تحديث التلاوة
    _planModel.recitationStartSurah =
        recitationStartSurahController.text.isEmpty
            ? null
            : recitationStartSurahController.text;
    _planModel.recitationEndSurah = recitationEndSurahController.text.isEmpty
        ? null
        : recitationEndSurahController.text;
    _planModel.recitationStartVerse =
        recitationStartVerseController.text.isEmpty
            ? null
            : int.tryParse(recitationStartVerseController.text);
    _planModel.recitationEndVerse = recitationEndVerseController.text.isEmpty
        ? null
        : int.tryParse(recitationEndVerseController.text);

    // تحديث المنفذ من التلاوة
    _planModel.executedRecitationStartSurah =
        executedRecitationStartSurahController.text.isEmpty
            ? null
            : executedRecitationStartSurahController.text;
    _planModel.executedRecitationEndSurah =
        executedRecitationEndSurahController.text.isEmpty
            ? null
            : executedRecitationEndSurahController.text;
    _planModel.executedRecitationStartVerse =
        executedRecitationStartVerseController.text.isEmpty
            ? null
            : int.tryParse(executedRecitationStartVerseController.text);
    _planModel.executedRecitationEndVerse =
        executedRecitationEndVerseController.text.isEmpty
            ? null
            : int.tryParse(executedRecitationEndVerseController.text);

    // تحديث الملاحظات
    _planModel.teacherNotes = teacherNotesController.text.isEmpty
        ? null
        : teacherNotesController.text;

    // تحديث تاريخ آخر تحديث
    _planModel.lastUpdated =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // حساب نسب الإنجاز
    _planModel.calculateConservationRate();
    _planModel.calculateRecitationRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خطة الطالب: ${widget.studentName}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'الحفظ'),
            Tab(text: 'التلاوة'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'حفظ الخطة',
            onPressed: _isLoading ? null : _savePlan,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // تبويب الحفظ
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('خطة الحفظ'),
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSurahSelection(
                                  'من سورة',
                                  conservationStartSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'من آية',
                                  conservationStartVerseController,
                                ),
                                SizedBox(height: 16),
                                _buildSurahSelection(
                                  'إلى سورة',
                                  conservationEndSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'إلى آية',
                                  conservationEndVerseController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildSectionTitle('ما تم إنجازه من الحفظ'),
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSurahSelection(
                                  'من سورة',
                                  executedConservationStartSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'من آية',
                                  executedConservationStartVerseController,
                                ),
                                SizedBox(height: 16),
                                _buildSurahSelection(
                                  'إلى سورة',
                                  executedConservationEndSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'إلى آية',
                                  executedConservationEndVerseController,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'نسبة الإنجاز: ${_planModel.conservationCompletionRate?.toStringAsFixed(1) ?? '0.0'}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value:
                                      (_planModel.conservationCompletionRate ??
                                              0) /
                                          100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // تبويب التلاوة
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('خطة التلاوة'),
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSurahSelection(
                                  'من سورة',
                                  recitationStartSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'من آية',
                                  recitationStartVerseController,
                                ),
                                SizedBox(height: 16),
                                _buildSurahSelection(
                                  'إلى سورة',
                                  recitationEndSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'إلى آية',
                                  recitationEndVerseController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        _buildSectionTitle('ما تم إنجازه من التلاوة'),
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSurahSelection(
                                  'من سورة',
                                  executedRecitationStartSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'من آية',
                                  executedRecitationStartVerseController,
                                ),
                                SizedBox(height: 16),
                                _buildSurahSelection(
                                  'إلى سورة',
                                  executedRecitationEndSurahController,
                                ),
                                SizedBox(height: 16),
                                _buildVerseInput(
                                  'إلى آية',
                                  executedRecitationEndVerseController,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'نسبة الإنجاز: ${_planModel.recitationCompletionRate?.toStringAsFixed(1) ?? '0.0'}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (_planModel.recitationCompletionRate ??
                                          0) /
                                      100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildSurahSelection(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        DropdownButton<String>(
          value: controller.text,
          items: surahs
              .map((String surah) => DropdownMenuItem<String>(
                    value: surah,
                    child: Text(surah),
                  ))
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.text = newValue;
            }
          },
        ),
      ],
    );
  }

  Widget _buildVerseInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يجب إدخال $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
