import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowAllTeacher extends StatefulWidget {
  const ShowAllTeacher({super.key});

  @override
  State<ShowAllTeacher> createState() => _ShowAllTeacherState();
}

class _ShowAllTeacherState extends State<ShowAllTeacher> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المعلمين"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Search",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // widget(child: Text("Filter by Schools")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
