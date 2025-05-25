import '../../models/user.dart';
import 'parent_conversation_list.dart';
import 'package:flutter/material.dart';

class ParentMainScreen extends StatefulWidget {
  final UserModel currentUser;

  const ParentMainScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ParentMainScreenState createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  List<UserModel> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    try {
      // ولي الأمر يحتاج فقط لرؤية المعلمين المرتبطين بالحلقة التي ينتمي إليها أبناؤه
      // Placeholder: In a real implementation, we would fetch teachers from a service
      // For now, we'll create a sample list of teachers for demonstration
      teachers = [
        UserModel(user_id: 1, first_name: 'معلم 1', roleID: 2),
        UserModel(user_id: 2, first_name: 'معلم 2', roleID: 2),
        UserModel(user_id: 3, first_name: 'معلم 3', roleID: 2),
      ];
      
      print('تم تحميل ${teachers.length} من المعلمين: ${teachers.map((t) => "${t.first_name} (ID: ${t.user_id})").toList()}');
    } catch (e) {
      print('خطأ في تحميل المعلمين: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل المعلمين'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('جاري التحميل...', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              SizedBox(height: 16),
              Text(
                'جاري تحميل بيانات المعلمين...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ParentConversationsScreen(
      currentUser: widget.currentUser,
      availableTeachers: teachers,
    );
  }
}
