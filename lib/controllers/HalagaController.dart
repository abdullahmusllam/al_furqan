import 'package:al_furqan/controllers/some_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/users_model.dart';
import 'package:al_furqan/services/firebase_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class HalagaController {
  final SqlDb _sqlDb = SqlDb();
  final List<HalagaModel> halagaData = [];
      
      Future<bool> isConnected() async {
    var conn = InternetConnectionChecker.createInstance().hasConnection;
    return conn ;
  }

  Future<List<HalagaModel>> getData(int id) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT E.halagaID, E.Name, E.NumberStudent, E.SchoolID, U.first_name, U.last_name, U.user_id "
        "FROM Elhalagat E "
        "LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 "
        "WHERE E.SchoolID = $id");

    print("--------------------------------------------");
    print("بيانات الحلقات التي تم جلبها من قاعدة البيانات:");
    for (var row in data) {
      print("halagaID: ${row['halagaID']}, Name: ${row['Name']}");
    }
    print("--------------------------------------------");

    List<HalagaModel> halagaData = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        int? halagaID = data[i]['halagaID'] as int?;
        String name = data[i]['Name'] ?? 'اسم غير متوفر';
        int numberStudent =
            int.tryParse(data[i]['NumberStudent'].toString()) ?? 0;
        int? schoolID = data[i]['SchoolID'] as int?;

        String? teacherName =
            (data[i]['first_name'] != null && data[i]['last_name'] != null)
                ? "${data[i]['first_name']} ${data[i]['last_name']}"
                : 'لا يوجد معلم للحلقة';

        halagaData.add(HalagaModel(
          halagaID: halagaID,
          Name: name,
          NumberStudent: numberStudent,
          SchoolID: schoolID,
          TeacherName: teacherName,
        ));
      }
    }
    print("تم جلب بيانات الحلقات: ${data.length}");
    return halagaData;
  }

  Future<List<UserModel>> getTeachers(int schoolID) async {
    List<Map> data = await _sqlDb.readData(
        "SELECT user_id, first_name, last_name, roleID, schoolID FROM Users WHERE schoolID = $schoolID AND roleID = 2");

    List<UserModel> teachers = [];

    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        int? userID = data[i]['userID'] as int?;
        String firstName = data[i]['first_name'] ?? 'اسم غير متوفر';
        String lastName = data[i]['last_name'] ?? 'اسم غير متوفر';
        int? roleID = data[i]['roleID'] as int?;
        int? schoolID = data[i]['schoolID'] as int?;

        teachers.add(UserModel(
          user_id: userID,
          first_name: firstName,
          last_name: lastName,
          roleID: roleID,
          schoolID: schoolID,
        ));
      }
    }
    print("تم جلب بيانات المعلمين: ${teachers.length}");
    return teachers;
  }

  Future<void> addHalaga(HalagaModel halagaData) async {
    try {
      halagaData.halagaID = await someController.newId("Elhalagat", "halagaID");
      final db = await sqlDb.database;
      // إضافة الحلقة
      if(await isConnected()){
        halagaData.isSync = 1;
        await db.insert('Elhalagat', halagaData.toMap());
        await firebasehelper.addHalga(halagaData);
      } else {
        halagaData.isSync = 0;
        await db.insert('Elhalagat', halagaData.toMap());
      }
      
      // إضافة خطة الحفظ إذا كانت متوفرة
      if (halagaData.conservationPlanStart != null &&
          halagaData.conservationPlanEnd != null) {
        int conservationPlanID = await someController.newId(
            "ConservationPlans", "ConservationPlanID");
        int conservationResponse = await _sqlDb.insertData(
            "INSERT INTO ConservationPlans (ConservationPlanID, ElhalagatID, PlannedStart, PlannedEnd) "
            "VALUES ($conservationPlanID, ${halagaData.halagaID}, '${halagaData.conservationPlanStart}', '${halagaData.conservationPlanEnd}')");
        print("تمت إضافة خطة الحفظ، الاستجابة: $conservationResponse");
      }

      // إضافة خطة التلاوة إذا كانت متوفرة
      if (halagaData.recitationPlanStart != null &&
          halagaData.recitationPlanEnd != null) {
        int recitationPlanID =
            await someController.newId("EltlawahPlans", "EltlawahPlanID");
        int recitationResponse = await _sqlDb.insertData(
            "INSERT INTO EltlawahPlans (EltlawahPlanID, ElhalagatID, PlannedStart, PlannedEnd) "
            "VALUES ($recitationPlanID, ${halagaData.halagaID}, '${halagaData.recitationPlanStart}', '${halagaData.recitationPlanEnd}')");
        print("تمت إضافة خطة التلاوة، الاستجابة: $recitationResponse");
      }

      // إضافة العلوم الشرعية إذا كانت متوفرة
      if (halagaData.islamicStudiesSubject != null) {
        int islamicStudiesID =
            await someController.newId("IslamicStudies", "IslamicStudiesID");
        int islamicStudiesResponse = await _sqlDb.insertData(
            "INSERT INTO IslamicStudies (IslamicStudiesID, ElhalagatID, Subject, PlannedContent) "
            "VALUES ($islamicStudiesID, ${halagaData.halagaID}, '${halagaData.islamicStudiesSubject}', "
            "'${halagaData.islamicStudiesContent ?? ''}')");
        print("تمت إضافة العلوم الشرعية، الاستجابة: $islamicStudiesResponse");
      }
    } catch (e) {
      print("خطأ في إضافة الحلقة: $e");
      rethrow;
    }
  }

  Future<void> updateHalaga(HalagaModel halaga, int? teacherId) async {
    try {
      // التحقق من صحة معرف الحلقة
      if (halaga.halagaID == null) {
        throw Exception("معرف الحلقة غير متوفر");
      }

      // التحقق من قيمة NumberStudent وتعيين قيمة افتراضية إذا كانت null
      int numberStudent = halaga.NumberStudent ?? 0;

      // تحديث بيانات الحلقة
      int response = await _sqlDb.updateData(
          "UPDATE Elhalagat SET Name = '${halaga.Name}', NumberStudent = $numberStudent WHERE halagaID = ${halaga.halagaID}");
      print("تم تحديث الحلقة ${halaga.halagaID}، الاستجابة: $response");
      if (response == 0) {
        throw Exception("فشل في تحديث الحلقة ${halaga.halagaID}");
      }

      try {
        // إلغاء ارتباط المعلم الحالي (إذا كان موجودًا)
        await _sqlDb.updateData(
            "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = ${halaga.halagaID} AND roleID = 2");
      } catch (e) {
        print("خطأ في إلغاء ارتباط المعلم الحالي: $e");
        // لا نرمي استثناء هنا لكي تستمر العملية
      }

      // ربط المعلم الجديد (إذا تم اختياره)
      if (teacherId != null) {
        try {
          int teacherResponse = await _sqlDb.updateData(
              "UPDATE Users SET ElhalagatID = ${halaga.halagaID} WHERE user_id = $teacherId AND roleID = 2");
          print(
              "تم تعيين المعلم $teacherId للحلقة ${halaga.halagaID}، الاستجابة: $teacherResponse");

          // نتحقق من نجاح العملية لكن لا نرمي استثناء هنا
          if (teacherResponse == 0) {
            print(
                "تحذير: تم تحديث الحلقة لكن قد تكون هناك مشكلة في تعيين المعلم");
          }
        } catch (e) {
          print("خطأ في تعيين المعلم الجديد: $e");
          // لا نرمي استثناء هنا لكي تستمر العملية
        }
      }
    } catch (e) {
      print("خطأ في تحديث الحلقة: $e");
      rethrow;
    }
  }

  Future<void> deleteHalaga(int halagaID) async {
    try {
      // إلغاء ارتباط الطلاب والمعلمين
      await _sqlDb.updateData(
          "UPDATE Students SET ElhalagatID = NULL WHERE ElhalagatID = $halagaID");
      await _sqlDb.updateData(
          "UPDATE Users SET ElhalagatID = NULL WHERE ElhalagatID = $halagaID");

      // حذف الحلقة
      int response = await _sqlDb
          .deleteData("DELETE FROM Elhalagat WHERE halagaID = $halagaID");
      print("تم حذف الحلقة $halagaID، الاستجابة: $response");
      if (response == 0) {
        throw Exception("فشل في حذف الحلقة $halagaID");
      }
    } catch (e) {
      print("خطأ في حذف الحلقة: $e");
      rethrow;
    }
  }

  Future<int> getStudentCount(int halagaID) async {
    try {
      final count = await _sqlDb.readData(
          "SELECT COUNT(*) as count FROM Students WHERE ElhalagatID = $halagaID");
      return count[0]['count'] as int;
    } catch (e) {
      print("خطأ في جلب عدد الطلاب: $e");
      return 0;
    }
  }

  Future<String> getTeacherNameByID(int? teacherID) async {
    if (teacherID == null) {
      return 'لا يوجد معلم للحلقة';
    }

    try {
      var teacherData = await _sqlDb.readData(
          'SELECT first_name, last_name FROM Users WHERE user_id = $teacherID AND roleID = 2');

      if (teacherData.isEmpty) {
        return 'معلم غير موجود';
      }

      return "${teacherData[0]['first_name']} ${teacherData[0]['last_name']}";
    } catch (e) {
      print('خطأ في جلب بيانات المعلم: $e');
      return 'خطأ في جلب بيانات المعلم';
    }
  }

  Future<HalagaModel?> getHalqaDetails(int halagaID) async {
    try {
      var response = await _sqlDb.readData(
          'SELECT E.*, U.first_name, U.last_name, U.user_id as TeacherID '
          'FROM Elhalagat E '
          'LEFT JOIN Users U ON U.ElhalagatID = E.halagaID AND U.roleID = 2 '
          'WHERE E.halagaID = $halagaID');

      if (response.isEmpty) {
        print('لا توجد بيانات للحلقة بالمعرف: $halagaID');
        return null;
      }

      var halagaData = response[0];
      String teacherName = 'لا يوجد معلم للحلقة';

      // إذا كان هناك معلم مرتبط بالحلقة
      if (halagaData['first_name'] != null && halagaData['last_name'] != null) {
        teacherName = "${halagaData['first_name']} ${halagaData['last_name']}";
      }

      HalagaModel halaga = HalagaModel(
        halagaID: halagaData['halagaID'],
        Name: halagaData['Name'],
        SchoolID: halagaData['SchoolID'],
        NumberStudent: halagaData['NumberStudent'] != null
            ? int.parse(halagaData['NumberStudent'].toString())
            : 0,
        TeacherName: teacherName,
        // بيانات الخطة - الحفظ والتلاوة وباقي البيانات كما هي
        conservationPlanStart: halagaData['conservationPlanStart'],
        conservationPlanEnd: halagaData['conservationPlanEnd'],
        conservationStartSurah: halagaData['conservationStartSurah'],
        conservationEndSurah: halagaData['conservationEndSurah'],
        conservationStartVerse: halagaData['conservationStartVerse'] != null
            ? int.parse(halagaData['conservationStartVerse'].toString())
            : null,
        conservationEndVerse: halagaData['conservationEndVerse'] != null
            ? int.parse(halagaData['conservationEndVerse'].toString())
            : null,
        // بيانات الخطة - التلاوة
        recitationPlanStart: halagaData['recitationPlanStart'],
        recitationPlanEnd: halagaData['recitationPlanEnd'],
        recitationStartSurah: halagaData['recitationStartSurah'],
        recitationEndSurah: halagaData['recitationEndSurah'],
        recitationStartVerse: halagaData['recitationStartVerse'] != null
            ? int.parse(halagaData['recitationStartVerse'].toString())
            : null,
        recitationEndVerse: halagaData['recitationEndVerse'] != null
            ? int.parse(halagaData['recitationEndVerse'].toString())
            : null,
        // بيانات التنفيذ - الحفظ والتلاوة
        executedStartSurah: halagaData['executedStartSurah'],
        executedEndSurah: halagaData['executedEndSurah'],
        executedStartVerse: halagaData['executedStartVerse'] != null
            ? int.parse(halagaData['executedStartVerse'].toString())
            : null,
        executedEndVerse: halagaData['executedEndVerse'] != null
            ? int.parse(halagaData['executedEndVerse'].toString())
            : null,
        // بيانات العلوم الشرعية
        islamicStudiesSubject: halagaData['islamicStudiesSubject'],
        islamicStudiesContent: halagaData['islamicStudiesContent'],
        executedIslamicContent: halagaData['executedIslamicContent'],
        islamicExecutionReason: halagaData['islamicExecutionReason'],
      );

      print('تم جلب بيانات الحلقة بنجاح: ${halaga.Name}');
      return halaga;
    } catch (e) {
      print('خطأ في جلب بيانات الحلقة: $e');
      return null;
    }
  }

  Future<void> updateHalagaPlans(HalagaModel halaga) async {
    try {
      if (halaga.halagaID == null) {
        throw Exception('معرف الحلقة مطلوب للتحديث');
      }

      // جلب بيانات الحلقة الحالية للاحتفاظ ببيانات التنفيذ
      HalagaModel? currentHalaga = await getHalqaDetails(halaga.halagaID!);
      if (currentHalaga != null) {
        // احتفظ ببيانات التنفيذ الحالية
        halaga.executedStartSurah = currentHalaga.executedStartSurah;
        halaga.executedEndSurah = currentHalaga.executedEndSurah;
        halaga.executedStartVerse = currentHalaga.executedStartVerse;
        halaga.executedEndVerse = currentHalaga.executedEndVerse;
        halaga.executedIslamicContent = currentHalaga.executedIslamicContent;
        halaga.islamicExecutionReason = currentHalaga.islamicExecutionReason;
      }

      // 1. تحديث خطة الحفظ
      if (halaga.conservationPlanStart != null &&
          halaga.conservationPlanEnd != null) {
        // التحقق من وجود خطة حفظ سابقة
        List<Map> existingPlans = await _sqlDb.readData(
            "SELECT ConservationPlanID FROM ConservationPlans WHERE ElhalagatID = ${halaga.halagaID}");

        if (existingPlans.isEmpty) {
          // إضافة خطة جديدة
          int conservationPlanID = await someController.newId(
              "ConservationPlans", "ConservationPlanID");
          await _sqlDb.insertData(
              "INSERT INTO ConservationPlans (ConservationPlanID, ElhalagatID, PlannedStart, PlannedEnd, StartSurah, EndSurah, StartVerse, EndVerse) "
              "VALUES ($conservationPlanID, ${halaga.halagaID}, '${halaga.conservationPlanStart}', '${halaga.conservationPlanEnd}', "
              "'${halaga.conservationStartSurah}', '${halaga.conservationEndSurah}', ${halaga.conservationStartVerse ?? 'NULL'}, ${halaga.conservationEndVerse ?? 'NULL'})");
        } else {
          // تحديث الخطة الموجودة
          await _sqlDb.updateData(
              "UPDATE ConservationPlans SET PlannedStart = '${halaga.conservationPlanStart}', "
              "PlannedEnd = '${halaga.conservationPlanEnd}', "
              "StartSurah = '${halaga.conservationStartSurah}', "
              "EndSurah = '${halaga.conservationEndSurah}', "
              "StartVerse = ${halaga.conservationStartVerse ?? 'NULL'}, "
              "EndVerse = ${halaga.conservationEndVerse ?? 'NULL'} "
              "WHERE ElhalagatID = ${halaga.halagaID}");
        }
      }

      // 2. تحديث خطة التلاوة
      if (halaga.recitationPlanStart != null &&
          halaga.recitationPlanEnd != null) {
        // التحقق من وجود خطة تلاوة سابقة
        List<Map> existingPlans = await _sqlDb.readData(
            "SELECT EltlawahPlanID FROM EltlawahPlans WHERE ElhalagatID = ${halaga.halagaID}");

        if (existingPlans.isEmpty) {
          // إضافة خطة جديدة
          int recitationPlanID =
              await someController.newId("EltlawahPlans", "EltlawahPlanID");
          await _sqlDb.insertData(
              "INSERT INTO EltlawahPlans (EltlawahPlanID, ElhalagatID, PlannedStart, PlannedEnd, StartSurah, EndSurah, StartVerse, EndVerse) "
              "VALUES ($recitationPlanID, ${halaga.halagaID}, '${halaga.recitationPlanStart}', '${halaga.recitationPlanEnd}', "
              "'${halaga.recitationStartSurah}', '${halaga.recitationEndSurah}', ${halaga.recitationStartVerse ?? 'NULL'}, ${halaga.recitationEndVerse ?? 'NULL'})");
        } else {
          // تحديث الخطة الموجودة
          await _sqlDb.updateData(
              "UPDATE EltlawahPlans SET PlannedStart = '${halaga.recitationPlanStart}', "
              "PlannedEnd = '${halaga.recitationPlanEnd}', "
              "StartSurah = '${halaga.recitationStartSurah}', "
              "EndSurah = '${halaga.recitationEndSurah}', "
              "StartVerse = ${halaga.recitationStartVerse ?? 'NULL'}, "
              "EndVerse = ${halaga.recitationEndVerse ?? 'NULL'} "
              "WHERE ElhalagatID = ${halaga.halagaID}");
        }
      }

      // 3. منفذ التلاوة (لا نقوم بتحديثه من هنا، فقط احتفظ به)
      // منفذ التلاوة يتم تحديثه من صفحة التفاصيل

      // 4. تحديث العلوم الشرعية
      if (halaga.islamicStudiesSubject != null) {
        // التحقق من وجود العلوم الشرعية
        List<Map> existingStudies = await _sqlDb.readData(
            "SELECT IslamicStudiesID FROM IslamicStudies WHERE ElhalagatID = ${halaga.halagaID}");

        if (existingStudies.isEmpty) {
          // إضافة علوم شرعية جديدة
          int islamicStudiesID =
              await someController.newId("IslamicStudies", "IslamicStudiesID");
          await _sqlDb.insertData(
              "INSERT INTO IslamicStudies (IslamicStudiesID, ElhalagatID, Subject, PlannedContent, ExecutedContent, ExecutionReason) "
              "VALUES ($islamicStudiesID, ${halaga.halagaID}, '${halaga.islamicStudiesSubject}', "
              "'${halaga.islamicStudiesContent ?? ''}', '${halaga.executedIslamicContent ?? ''}', '${halaga.islamicExecutionReason ?? ''}')");
        } else {
          // تحديث العلوم الشرعية الموجودة، مع الاحتفاظ ببيانات التنفيذ الحالية
          await _sqlDb.updateData(
              "UPDATE IslamicStudies SET Subject = '${halaga.islamicStudiesSubject}', "
              "PlannedContent = '${halaga.islamicStudiesContent ?? ''}', "
              "ExecutedContent = '${halaga.executedIslamicContent ?? ''}', "
              "ExecutionReason = '${halaga.islamicExecutionReason ?? ''}' "
              "WHERE ElhalagatID = ${halaga.halagaID}");
        }
      }

      print("تم تحديث خطط الحلقة ${halaga.halagaID} بنجاح");
    } catch (e) {
      print("خطأ في تحديث خطط الحلقة: $e");
      rethrow;
    }
  }

  Future<List<HalagaModel>> getHalagaByHalagaID(int halagaID) async {
    List<Map<String, dynamic>> halagaData = await _sqlDb
        .readData("SELECT * FROM Elhalagat WHERE halagaID = $halagaID");
    return halagaData.map((halaga) => HalagaModel.fromJson(halaga)).toList();
  }
}

HalagaController halagaController = HalagaController();
