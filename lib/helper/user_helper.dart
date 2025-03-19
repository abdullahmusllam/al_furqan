import 'package:al_furqan/controllers/users_controller.dart'; // استيراد وحدة التحكم بالمستخدمين للوصول إلى العمليات المتعلقة بالمستخدمين.
import 'package:al_furqan/models/users_model.dart'; // استيراد نموذج المستخدم لتمثيل بيانات المستخدم.
import 'package:flutter/cupertino.dart'; // استيراد حزمة Cupertino من Flutter لعناصر واجهة المستخدم.
import 'package:shared_preferences/shared_preferences.dart'; // استيراد SharedPreferences للتخزين الدائم.

class UserHelper {
  // فئة مساعدة للعمليات المتعلقة بالمستخدم.
  static Future<UserModel?> getDataByPref() async {
    // دالة ثابتة لجلب بيانات المستخدم من SharedPreferences.
    final pref = await SharedPreferences
        .getInstance(); // الحصول على مثيل SharedPreferences.
    String? phoneUser = pref.getString(
        'phoneUser'); // استرجاع رقم الهاتف المحفوظ من SharedPreferences.

    if (phoneUser == null) {
      // التحقق إذا لم يكن هناك رقم هاتف محفوظ.
      print(
          "لا يوجد رقم هاتف محفوظ في SharedPreferences"); // طباعة رسالة توضح عدم وجود رقم هاتف محفوظ.
      return null; // إرجاع null لأنه لا توجد بيانات مستخدم.
    }

    await userController.getDataUsers(); // جلب قائمة المستخدمين من وحدة التحكم.
    print(
        "userList: ${userController.users.isEmpty}"); // طباعة ما إذا كانت قائمة المستخدمين فارغة.

    for (var element in userController.users) {
      // التكرار عبر قائمة المستخدمين.
      if (int.tryParse(phoneUser) == element.phone_number) {
        // التحقق إذا كان رقم الهاتف المحفوظ يطابق رقم هاتف المستخدم.
        print(
            "---------------------------------------------"); // طباعة فاصل للتوضيح أثناء التصحيح.
        return element; // إرجاع المستخدم المطابق.
      }
    }
    print(
        "لم يتم العثور على مستخدم برقم الهاتف: $phoneUser"); // طباعة رسالة توضح عدم العثور على مستخدم برقم الهاتف.
    return null; // إرجاع null لأنه لم يتم العثور على مستخدم مطابق.
  }
}

mixin UserDataMixin<T extends StatefulWidget> on State<T> {
  // مزيج لإضافة وظيفة جلب بيانات المستخدم إلى StatefulWidget.
  UserModel? user; // متغير لتخزين بيانات المستخدم التي تم جلبها.
  bool _isLoading = true; // متغير خاص لتتبع حالة التحميل.

  bool get isLoading => _isLoading; // دالة getter لإظهار حالة التحميل.

  Future<void> fetchUserData() async {
    // دالة لجلب بيانات المستخدم بشكل غير متزامن.
    setState(() =>
        _isLoading = true); // تعيين حالة التحميل إلى true قبل جلب البيانات.
    user = await UserHelper
        .getDataByPref(); // جلب بيانات المستخدم باستخدام فئة UserHelper.
    setState(() =>
        _isLoading = false); // تعيين حالة التحميل إلى false بعد جلب البيانات.
  }

  @override
  void initState() {
    // تجاوز دالة initState الخاصة بـ StatefulWidget.
    super.initState(); // استدعاء دالة initState الخاصة بالفئة الأم.
    fetchUserData(); // جلب بيانات المستخدم عند تهيئة الويدجت.
  }
}
