import 'package:al_furqan/controllers/users_controller.dart';
import 'package:al_furqan/helper/sqldb.dart';
import 'package:al_furqan/views/Supervisor/add_user.dart';
import 'package:flutter/material.dart';
import 'package:al_furqan/widgets/requests_list.dart';
import 'package:al_furqan/widgets/user_list.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  String? _selectedRole;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SqlDb sqlDb = SqlDb();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    await userController.get_data();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'تحديث البيانات',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'المستخدمين'),
            Tab(text: 'الطلبات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserList(), // Use the new widget
          RequestsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddUser()))
              .then((_) {
            _refreshData();
          });
        },
        tooltip: 'إضافة مستخدم جديد',
        child: Icon(Icons.add),
      ),
    );
  }
}
