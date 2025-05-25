import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'dart:async';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // جلب بيانات الطالب
  Future<Student?> getStudent(String studentId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Students').doc(studentId).get();
      if (doc.exists) {
        return Student.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب بيانات الطالب: $e');
      return null;
    }
  }
  
  // جلب بيانات الطلاب المرتبطين بولي الأمر
  Future<List<Student>> getStudentsByParentId(int parentId) async {
    try {
      // البحث عن الطلاب المرتبطين بولي الأمر باستخدام حقل userID
      QuerySnapshot userIdSnapshot = await _db
          .collection('Students')
          .where('userID', isEqualTo: parentId)
          .get();
      
      // طباعة عدد الطلاب المسترجعين للتصحيح
      print('عدد الطلاب المسترجعين: ${userIdSnapshot.docs.length}');
      print('معرف ولي الأمر المستخدم في البحث: $parentId');
      
      // تحويل النتائج إلى قائمة من الطلاب
      List<Student> students = userIdSnapshot.docs
          .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      return students;
    } catch (e) {
      print('خطأ في جلب بيانات الطلاب بواسطة معرف ولي الأمر: $e');
      return [];
    }
  }
  
  // جلب اسم المدرسة بواسطة معرف المدرسة
  Future<String> getSchoolName(int? schoolId) async {
    if (schoolId == null) return 'غير محدد';
    
    try {
      QuerySnapshot snapshot = await _db
          .collection('School')
          .where('SchoolID', isEqualTo: schoolId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('school_name') as String? ?? 'غير محدد';
      }
      return 'غير محدد';
    } catch (e) {
      print('خطأ في جلب اسم المدرسة: $e');
      return 'غير محدد';
    }
  }
  
  // جلب اسم الحلقة بواسطة معرف الحلقة
  Future<String> getHalagaName(int? halagaId) async {
    if (halagaId == null) return 'غير محدد';
    
    try {
      QuerySnapshot snapshot = await _db
          .collection('Elhalaga')
          .where('halagaID', isEqualTo: halagaId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('Name') as String? ?? 'غير محدد';
      }
      return 'غير محدد';
    } catch (e) {
      print('خطأ في جلب اسم الحلقة: $e');
      return 'غير محدد';
    }
  }
  
  // جلب بيانات الطالب بواسطة معرف المستخدم (ولي الأمر)
  Future<Student?> getStudentByUserId(String userId) async {
    try {
      // أولاً نجلب بيانات المستخدم (ولي الأمر)
      UserModel? user = await getUser(userId);
      if (user != null) {
        // نفترض أن لدينا علاقة بين ولي الأمر والطالب في قاعدة البيانات
        // نبحث عن الطالب المرتبط بولي الأمر
        List<Student> students = await getStudentsByParentId(user.user_id!);
        if (students.isNotEmpty) {
          return students.first; // نعيد أول طالب مرتبط بولي الأمر
        }
      }
      return null;
    } catch (e) {
      print('خطأ في جلب بيانات الطالب بواسطة معرف المستخدم: $e');
      return null;
    }
  }

  // جلب بيانات المستخدم بواسطة المعرف
  Future<UserModel?> getUser(dynamic userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Users').doc(userId.toString()).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }
  
  // جلب بيانات المستخدم بواسطة رقم الهاتف
  Future<UserModel?> getUserByPhone(int phoneNumber) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم بواسطة رقم الهاتف: $e');
      return null;
    }
  }
  
  // التحقق من بيانات المستخدم (تسجيل الدخول)
  Future<UserModel?> authenticate(int phoneNumber, String password) async {
    try {
      // البحث عن المستخدم بواسطة رقم الهاتف
      UserModel? user = await getUserByPhone(phoneNumber);
      
      // طباعة معلومات للتصحيح
      print('رقم الهاتف: $phoneNumber');
      print('كلمة المرور المدخلة: $password');
      print('نوع كلمة المرور المدخلة: ${password.runtimeType}');
      
      if (user != null) {
        print('كلمة المرور المخزنة: ${user.password}');
        print('نوع كلمة المرور المخزنة: ${user.password.runtimeType}');
        
        // التحقق من وجود المستخدم وصحة كلمة المرور
        // مقارنة كلمة المرور بعد تحويلها لنفس النوع
        if (user.password.toString() == password) {
          // التحقق من أن المستخدم هو ولي أمر (roleID = 3)
          if (user.roleID == 3) {
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      print('خطأ في التحقق من بيانات المستخدم: $e');
      return null;
    }
  }

  // جلب المدرسين والمدير
  Future<List<UserModel>> getTeachersAndPrincipal() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('role', whereIn: ['1', '2'])
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('خطأ في جلب المدرسين والمدير: $e');
      return [];
    }
  }

  // إرسال رسالة
  Future<void> sendMessage(Message message) async {
    try {
      await _db.collection('messages').add(message.toMap());
    } catch (e) {
      print('خطأ في إرسال الرسالة: $e');
    }
  }

  // جلب الرسائل
  Future<List<Message>> getMessages(String senderId, String receiverId, String circleId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('messages')
          .where('senderId', whereIn: [senderId, receiverId])
          .where('receiverId', whereIn: [senderId, receiverId])
          .where('circleId', isEqualTo: circleId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Message.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('خطأ في جلب الرسائل: $e');
      return [];
    }
  }
  
  // جلب المدرسين حسب معرف الحلقة
  Future<List<UserModel>> getTeachersByCircleId(int circleId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('roleID', isEqualTo: 2) // المدرسين فقط (roleID = 2)
          .where('ElhalagatID', isEqualTo: circleId)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('خطأ في جلب المدرسين حسب معرف الحلقة: $e');
      return [];
    }
  }
  
  // جلب مدير المدرسة بواسطة معرف المدرسة
  Future<UserModel?> getSchoolPrincipal(int schoolId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('roleID', isEqualTo: 1) // مدير المدرسة فقط (roleID = 1)
          .where('schoolID', isEqualTo: schoolId)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب مدير المدرسة: $e');
      return null;
    }
  }
  
  // إضافة طلب تسجيل جديد
  Future<void> addRequest(UserModel user) async {
    try {
      // إضافة طلب التسجيل إلى مجموعة Requests في Firestore
      await _db.collection('Requests').add(user.toMap());
    } catch (e) {
      print('خطأ في إضافة طلب التسجيل: $e');
      throw e; // إعادة رمي الخطأ ليتم التعامل معه في الشاشة
    }
  }
}

FirestoreService firestoreService = FirestoreService();