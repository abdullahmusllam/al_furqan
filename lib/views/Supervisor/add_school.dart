import 'package:al_furqan/controllers/school_controller.dart';
import 'package:flutter/material.dart';

import '../../models/schools_model.dart';

class AddSchool extends StatefulWidget {
  const AddSchool({super.key});

  @override
  State<AddSchool> createState() => _AddSchoolState();
}

class _AddSchoolState extends State<AddSchool> {
  final _schoolNameController = TextEditingController();
  final _schoolLocationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    await schoolController.get_data();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مدرسة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _schoolNameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المدرسة',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء كتابة اسم المدرسة';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _schoolLocationController,
                    decoration: InputDecoration(
                      labelText: 'موقع المدرسة',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء كتابة موقع المدرسة';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await schoolController.add_School(SchoolModel(
                          school_name: _schoolNameController.text,
                          school_location: _schoolLocationController.text,
                        ));
                        await _loadSchools();
                        _schoolNameController.clear();
                        _schoolLocationController.clear();
                      }
                    },
                    child: Text('إضافة مدرسة'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schoolController.schools.length,
                itemBuilder: (context, index) {
                  final school = schoolController.schools[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text("${school.schoolID}"),
                    ),
                    title: Text(school.school_name!),
                    subtitle: Text(school.school_location!),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('تأكيد الحذف'),
                            content:
                                Text('هل أنت متأكد أنك تريد حذف هذه المدرسة؟'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                        );
                        if (confirmDelete) {
                          await schoolController
                              .delete_School(school.schoolID!);
                          await _loadSchools();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
