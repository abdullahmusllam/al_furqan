import 'package:flutter/material.dart';
import '../models/student.dart';
import '../service/fierbase_service.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  String _schoolName = 'جاري التحميل...';
  String _halagaName = 'جاري التحميل...';
  bool _isLoading = true;
  
  // متغيرات لخطة الحفظ
  bool _isLoadingPlan = true;
  Map<String, dynamic>? _conservationPlan;

  @override
  void initState() {
    super.initState();
    _loadSchoolAndHalagaNames();
    _loadConservationPlan();
  }

  Future<void> _loadSchoolAndHalagaNames() async {
    try {
      final schoolName = await firestoreService.getSchoolName(widget.student.schoolID);
      final halagaName = await firestoreService.getHalagaName(widget.student.elhalagatID);
      
      if (mounted) {
        setState(() {
          _schoolName = schoolName;
          _halagaName = halagaName;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات المدرسة والحلقة: $e');
      if (mounted) {
        setState(() {
          _schoolName = 'غير محدد';
          _halagaName = 'غير محدد';
          _isLoading = false;
        });
      }
    }
  }
  
  // تحميل خطة الحفظ للطالب
  Future<void> _loadConservationPlan() async {
    try {
      final plan = await firestoreService.getStudentConservationPlan(widget.student.studentID);
      
      if (mounted) {
        setState(() {
          _conservationPlan = plan;
          _isLoadingPlan = false;
        });
      }
    } catch (e) {
      print('خطأ في تحميل خطة الحفظ: $e');
      if (mounted) {
        setState(() {
          _conservationPlan = null;
          _isLoadingPlan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطالب', style: TextStyle(fontFamily: 'RB', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF017546),
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث البيانات',
              onPressed: _loadSchoolAndHalagaNames,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F0), Colors.white], // Light version of #017546
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // رأس الصفحة مع اسم الطالب
              _buildProfileHeader(context),
              
              SizedBox(height: 16),
              
              // بطاقات معلومات المدرسة والحلقة
              // استخدام SizedBox بدلاً من IntrinsicHeight لتحديد ارتفاع ثابت
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSchoolInfoCard(
                        context,
                        title: 'المدرسة',
                        icon: Icons.school,
                        value: _isLoading ? 'جاري التحميل...' : _schoolName,
                        isLoading: _isLoading,
                      ),
                    ),
                    SizedBox(width: 8), // تقليل المسافة بين البطاقات
                    Expanded(
                      child: _buildSchoolInfoCard(
                        context,
                        title: 'الحلقة',
                        icon: Icons.book,
                        value: _isLoading ? 'جاري التحميل...' : _halagaName,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // بطاقة خطة الحفظ
              _buildConservationPlanCard(context),
              
              SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF017546).withOpacity(0.8),
                      Color(0xFF017546),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF017546).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'الحضور والغياب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'RB',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildAttendanceStats(context),
                      // عرض الأعذار والغياب بتصميم محسن
                      if (widget.student.excuse.isNotEmpty || widget.student.reasonAbsence.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note_alt, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'معلومات الغياب والأعذار',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RB', color: Colors.white),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white.withOpacity(0.3), height: 24),
                              if (widget.student.excuse.isNotEmpty) ...[  
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.medical_services_outlined, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'عذر الغياب:',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'RB', color: Colors.white),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              widget.student.excuse,
                                              style: TextStyle(fontSize: 14, fontFamily: 'RB', color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (widget.student.excuse.isNotEmpty && widget.student.reasonAbsence.isNotEmpty)
                                SizedBox(height: 16),
                              if (widget.student.reasonAbsence.isNotEmpty) ...[  
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'سبب الغياب:',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'RB', color: Colors.white),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              widget.student.reasonAbsence,
                                              style: TextStyle(fontSize: 14, fontFamily: 'RB', color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  // بناء رأس ملف الطالب
  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade200.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF017546),
            child: Text(
              widget.student.firstName.isNotEmpty ? widget.student.firstName.substring(0, 1) : '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'RB',
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          widget.student.fullName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'RB',
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
  
  // تم إزالة الدوال غير المستخدمة
  
  // بناء إحصائيات الحضور
  Widget _buildAttendanceStats(BuildContext context) {
    // حساب نسبة الحضور
    int attendance = widget.student.attendanceDays ?? 0;
    int absence = widget.student.absenceDays ?? 0;
    int total = attendance + absence;
    double attendancePercentage = total > 0 ? (attendance / total) * 100 : 0;
    
    // تحديد لون شريط التقدم بناءً على نسبة الحضور
    Color progressColor;
    String statusText;
    IconData statusIcon;
    
    if (attendancePercentage > 90) {
      progressColor = Colors.white;
      statusText = 'ممتاز';
      statusIcon = Icons.emoji_events;
    } else if (attendancePercentage > 75) {
      progressColor = Colors.white;
      statusText = 'جيد جدًا';
      statusIcon = Icons.thumb_up;
    } else if (attendancePercentage > 60) {
      progressColor = Colors.white.withOpacity(0.9);
      statusText = 'جيد';
      statusIcon = Icons.check_circle;
    } else if (attendancePercentage > 50) {
      progressColor = Colors.white.withOpacity(0.8);
      statusText = 'مقبول';
      statusIcon = Icons.info;
    } else {
      progressColor = Colors.white.withOpacity(0.7);
      statusText = 'ضعيف';
      statusIcon = Icons.warning;
    }
    
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'نسبة الحضور:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RB', color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${attendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RB',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RB',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: total > 0 ? attendance / total : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              progressColor.withOpacity(0.7),
                              progressColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildAttendanceItem('أيام الحضور', attendance, Colors.white, Icons.check_circle),
            _buildAttendanceItem('أيام الغياب', absence, Colors.white.withOpacity(0.9), Icons.cancel),
          ],
        ),
      ],
    );
  }
  
  // بناء بطاقة معلومات المدرسة أو الحلقة
  Widget _buildSchoolInfoCard(BuildContext context, {required String title, required IconData icon, required String value, required bool isLoading}) {
    return Container(
      height: 90, // تقليل الارتفاع من 100 إلى 90
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // تقليل نصف قطر الزاوية
        border: Border.all(color: Color(0xFFE8F5F0), width: 1),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // تقليل الحشو الداخلي
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6), // تقليل الحشو الداخلي للأيقونة
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF017546), size: 18), // تقليل حجم الأيقونة
              ),
              SizedBox(height: 6), // تقليل المسافة
              Text(
                title,
                style: TextStyle(
                  fontSize: 13, // تقليل حجم الخط
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RB',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2), // تقليل المسافة
              isLoading
                ? SizedBox(
                    height: 10, // تقليل حجم مؤشر التحميل
                    width: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017546)),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11, // تقليل حجم الخط
                      fontFamily: 'RB',
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء بطاقة خطة الحفظ
  Widget _buildConservationPlanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFF017546)),
              SizedBox(width: 8),
              Text(
                'خطة الحفظ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RB',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Divider(height: 24, thickness: 1),
          _isLoadingPlan
              ? Center(child: CircularProgressIndicator(color: Color(0xFF017546)))
              : _conservationPlan == null
                  ? Center(
                      child: Text(
                        'لا توجد خطة حفظ متوفرة',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RB',
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // المقرر للحفظ
                        _buildPlanSection(
                          title: 'مقرر الحفظ',
                          icon: Icons.assignment,
                          color: Color(0xFF017546),
                          content: _buildPlanContent(
                            startSurah: _conservationPlan!['PlannedStartSurah'] ?? '',
                            startAya: _conservationPlan!['PlannedStartAya'],
                            endSurah: _conservationPlan!['PlannedEndSurah'] ?? '',
                            endAya: _conservationPlan!['PlannedEndAya'],
                          ),
                        ),
                        SizedBox(height: 16),
                        // المنفذ من الحفظ
                        _buildPlanSection(
                          title: 'المنفذ من الحفظ',
                          icon: Icons.check_circle,
                          color: Colors.blue,
                          content: _conservationPlan!['ExecutedStartSurah'] == null
                              ? 'لم يتم تسجيل أي تقدم بعد'
                              : _buildPlanContent(
                                  startSurah: _conservationPlan!['ExecutedStartSurah'] ?? '',
                                  startAya: _conservationPlan!['ExecutedStartAya'],
                                  endSurah: _conservationPlan!['ExecutedEndSurah'] ?? '',
                                  endAya: _conservationPlan!['ExecutedEndAya'],
                                ),
                        ),
                        if (_conservationPlan!['ExecutedRate'] != null) ...[  
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.percent, color: Colors.amber, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'نسبة الإنجاز: ${_conservationPlan!['ExecutedRate']}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RB',
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'شهر الخطة: ${_conservationPlan!['PlanMonth'] ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'RB',
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
        ],
      ),
    );
  }
  
  // بناء قسم من خطة الحفظ
  Widget _buildPlanSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'RB',
                color: color,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 26, top: 8),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'RB',
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  // بناء محتوى خطة الحفظ
  String _buildPlanContent({
    required String startSurah,
    required dynamic startAya,
    required String endSurah,
    required dynamic endAya,
  }) {
    if (startSurah.isEmpty || endSurah.isEmpty) {
      return 'غير محدد';
    }
    
    return 'من $startSurah آية ${startAya ?? ''} إلى $endSurah آية ${endAya ?? ''}';
  }

  Widget _buildAttendanceItem(String label, int value, Color color, IconData icon) {
    double cardWidth = MediaQuery.of(context).size.width > 400 ? 100 : 90;
    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'RB',
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'RB',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}