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
    await userController.getData();
    setState(() {});
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddUser()))
            .then((_) {
          _refreshData();
        });
      },
      tooltip: 'إضافة مستخدم جديد',
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserList(),
          RequestsList(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
