import 'package:al_furqan/controllers/school_controller.dart';
import 'package:al_furqan/models/schools_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowAllSchools extends StatefulWidget {
  const ShowAllSchools({super.key});

  @override
  State<ShowAllSchools> createState() => _ShowAllSchoolsState();
}

class _ShowAllSchoolsState extends State<ShowAllSchools> {
  String _searchQuery = '';
  bool _isLoading = false;

  List<SchoolModel> _filterSchools() {
    if (_searchQuery.isEmpty) return schoolController.schools;
    return schoolController.schools.where((school) {
      final fullName = '${school.school_name ?? ''}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Function to fetch teachers and schools data
  void _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await schoolController.getData();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب البيانات: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    List<SchoolModel> _schools = schoolController.schools;
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(
          "المدارس",
          style: TextStyle(fontFamily: 'RB'),
        ),
        backgroundColor: CupertinoColors.activeGreen.withOpacity(0.5),
        automaticBackgroundVisibility: false,
        enableBackgroundFilterBlur: true,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'بحث',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: ListView.builder(
                      itemCount: _filterSchools().length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            child: Text("${index + 1}"),
                          ),
                          title: Text(_schools[index].school_name!),
                          subtitle: Text(_schools[index].school_location!),
                        );
                      },
                    ),
                  ),
          )
        ],
      )),
    );
  }
}
