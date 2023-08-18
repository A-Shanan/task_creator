// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'package:flutter/material.dart';
import 'package:task_creator/screens/Manager/task_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeDetailsScreen extends StatefulWidget {
  Map<String, dynamic> employeeData;
  EmployeeDetailsScreen({super.key, required this.employeeData});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4a171e),
      appBar: AppBar(
        backgroundColor: const Color(0xff4a171e),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.employeeData["name"],
          style: const TextStyle(
              color: Color(0xffffc23c),
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add new task'),
                    content: TaskForm(employeeId: widget.employeeData['id']),
                  ),
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: ListView.builder(
          itemCount: widget.employeeData["tasks"].length,
          itemBuilder: (context, index) {
            return widget.employeeData["tasks"].length > 0
                ? Card(
                    color: const Color(0xfffff3cd),
                    child: ExpansionTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                showEditDialog(index);
                              },
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () {
                                final taskId =
                                    widget.employeeData["tasks"][index]["id"];
                                http
                                    .delete(Uri.parse(
                                        'http://10.0.2.2:8000/api/v1/tasks/$taskId'))
                                    .then((response) {
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      widget.employeeData["tasks"]
                                          .removeAt(index);
                                    });
                                  } else {
                                    print(
                                        'Failed to delete task. Status code: ${response.statusCode}');
                                  }
                                }).catchError((error) {
                                  print('Error deleting task: $error');
                                });
                              },
                              icon: const Icon(Icons.delete_forever_outlined)),
                        ],
                      ),
                      title: Text(
                        widget.employeeData["tasks"][index]["title"],
                        style: const TextStyle(
                            color: Color(0xffff926b),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 18, right: 18, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DESCRIPTION: ${widget.employeeData["tasks"][index]["description"]}',
                                  style: const TextStyle(
                                      color: Color(0xffff926b), fontSize: 18),
                                ),
                                if (widget.employeeData["tasks"][index]
                                        ["isPending"] ==
                                    1)
                                  const Text(
                                    'Pending: Yes',
                                    style: TextStyle(
                                        color: Color(0xffff926b), fontSize: 18),
                                  ),
                                if (widget.employeeData["tasks"][index]
                                        ["isCompleted"] ==
                                    1)
                                  const Text(
                                    'Completed: Yes',
                                    style: TextStyle(
                                        color: Color(0xffff926b), fontSize: 18),
                                  ),
                                if (widget.employeeData["tasks"][index]
                                            ["isCompleted"] ==
                                        0 &&
                                    widget.employeeData["tasks"][index]
                                            ["isPending"] ==
                                        0 &&
                                    widget.employeeData["tasks"][index]
                                            ["isRejected"] ==
                                        0)
                                  const Text(
                                    'Completed: in progress',
                                    style: TextStyle(
                                        color: Color(0xffff926b), fontSize: 18),
                                  ),
                                if (widget.employeeData["tasks"][index]
                                            ["isCompleted"] ==
                                        0 &&
                                    widget.employeeData["tasks"][index]
                                            ["isPending"] ==
                                        0 &&
                                    widget.employeeData["tasks"][index]
                                            ["isRejected"] ==
                                        1)
                                  const Text(
                                    'Completed: Rejected',
                                    style: TextStyle(
                                        color: Color(0xffff926b), fontSize: 18),
                                  ),
                                if (widget.employeeData["tasks"][index]
                                        ["isRejected"] ==
                                    1)
                                  const Text(
                                    'Rejected: Yes',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18),
                                  ),
                                if (widget.employeeData["tasks"][index]
                                        ["rejectReason"] !=
                                    null)
                                  Text(
                                    'Rejection reason: ${widget.employeeData["tasks"][index]["rejectReason"]}',
                                    style: const TextStyle(
                                        color: Color(0xffff926b), fontSize: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'data',
                    style: TextStyle(fontSize: 100, color: Colors.amber),
                  );
          },
        ),
      ),
    );
  }

  Future<void> handleRefresh() async {
    final employeeId = widget.employeeData['id'];
    http
        .get(Uri.parse('http://10.0.2.2:8000/api/v1/employees/$employeeId'))
        .then((response) {
      if (response.statusCode == 200) {
        final updatedEmployeeData = json.decode(response.body);
        setState(() {
          widget.employeeData = updatedEmployeeData;
        });
      } else {
        print('Failed to refresh tasks. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error refreshing tasks: $error');
    });
  }

  void showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String updatedTitle = widget.employeeData["tasks"][index]["title"];
        String updatedDescription =
            widget.employeeData["tasks"][index]["description"];

        return AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    updatedTitle = value;
                  },
                  controller: TextEditingController(text: updatedTitle),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    updatedDescription = value;
                  },
                  controller: TextEditingController(text: updatedDescription),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateTask(index, updatedTitle, updatedDescription);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void updateTask(int index, String updatedTitle, String updatedDescription) {
    final taskId = widget.employeeData["tasks"][index]["id"];

    http.put(Uri.parse('http://10.0.2.2:8000/api/v1/tasks/$taskId'), body: {
      'title': updatedTitle,
      'description': updatedDescription,
    }).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          widget.employeeData["tasks"][index]["title"] = updatedTitle;
          widget.employeeData["tasks"][index]["description"] =
              updatedDescription;
        });
      } else {
        print('Failed to update task. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error updating task: $error');
    });
  }
}
