import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String? selectedRole;
  final int? selectedSchoolId;
  final List<DropdownMenuItem<int>> schoolItems;
  final Function(String?, int?) onApply;

  FilterDialog({
    required this.selectedRole,
    required this.selectedSchoolId,
    required this.schoolItems,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? tempSelectedRole;
  int? tempSelectedSchoolId;

  @override
  void initState() {
    super.initState();
    tempSelectedRole = widget.selectedRole;
    tempSelectedSchoolId = widget.selectedSchoolId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تصفية المستخدمين'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: tempSelectedRole,
            decoration: InputDecoration(
              labelText: 'اختر الدور',
              border: OutlineInputBorder(),
            ),
            items: <String>['مشرف', 'مدير', 'معلم'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                tempSelectedRole = newValue;
              });
            },
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: tempSelectedSchoolId,
            decoration: InputDecoration(
              labelText: 'اختر المدرسة',
              border: OutlineInputBorder(),
            ),
            items: widget.schoolItems,
            onChanged: (newValue) {
              setState(() {
                tempSelectedSchoolId = newValue;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(tempSelectedRole, tempSelectedSchoolId);
            Navigator.of(context).pop();
          },
          child: Text('تطبيق'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(null, null);
            Navigator.of(context).pop();
          },
          child: Text('إزالة التصفية'),
        ),
      ],
    );
  }
}
