// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const TaskDetailsScreen({
    Key? key,
    required this.taskData,
  }) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4a171e),
      appBar: AppBar(
        backgroundColor: const Color(0xff4a171e),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.taskData['title'] ?? '',
          style: const TextStyle(
              color: Color(0xffffc23c),
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.taskData['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 25,
                    color: Color(0xffffc23c),
                  ),
                ),
                if (widget.taskData['isPending'] == 1 &&
                    widget.taskData['isRejected'] == 0 &&
                    widget.taskData['isCompleted'] == 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          updateTaskIsPending(0);
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Color(0xff4a171e),
                          size: 24.0,
                        ),
                        label: const Text(
                          'Accept',
                          style: TextStyle(
                            color: Color(0xff4a171e),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffc23c),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showEditDialog();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xff4a171e),
                          size: 24.0,
                        ),
                        label: const Text(
                          'Reject',
                          style: TextStyle(
                            color: Color(0xff4a171e),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffc23c),
                        ),
                      ),
                    ],
                  ),
                ] else if ((widget.taskData['isPending'] == 0 &&
                    widget.taskData['isRejected'] == 1 &&
                    widget.taskData['isCompleted'] == 0)) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Card(
                        color: const Color(0xfffff3cd),
                        child: RichText(
                          text: const TextSpan(
                            text: 'This task is  ',
                            style: TextStyle(
                                fontSize: 25, color: Color(0xffffc23c)),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'REJECTED',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (widget.taskData['isPending'] == 0 &&
                    widget.taskData['isRejected'] == 0 &&
                    widget.taskData['isCompleted'] == 0) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      taskCompleted(0, 0, 1);
                    },
                    icon: const Icon(
                      Icons.check_circle,
                      color: Color(0xff4a171e),
                      size: 24.0,
                    ),
                    label: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(0xff4a171e),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffffc23c),
                    ),
                  ),
                ] else if (widget.taskData['isPending'] == 0 &&
                    widget.taskData['isRejected'] == 0 &&
                    widget.taskData['isCompleted'] == 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Card(
                        color: const Color(0xfffff3cd),
                        child: RichText(
                          text: const TextSpan(
                            text: 'This task is  ',
                            style: TextStyle(
                                fontSize: 25, color: Color(0xffffc23c)),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'COMPLETED',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffffc23c)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future updateTaskIsPending(int isPending) async {
    final taskId = widget.taskData["id"];
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/v1/tasks/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, int>{
        'isPending': isPending,
      }),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 302) {
        print('the task updated');
        setState(() {
          widget.taskData["isPending"] = isPending;
        });
      } else {
        print('Failed to update task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error $e');
    }
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String updatedRejectReason = widget.taskData["rejectReason"] ?? "";

        return AlertDialog(
          title: const Text('Why you Reject the task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    updatedRejectReason = value;
                  },
                  controller: TextEditingController(text: updatedRejectReason),
                  decoration: const InputDecoration(
                    labelText: 'Reason',
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
                updateTaskIsRejected(0, 1, 0, updatedRejectReason);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future updateTaskIsRejected(int isPending, int isRejected, int isCompleted,
      String rejectReason) async {
    final taskId = widget.taskData["id"];
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/v1/tasks/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'isPending': isPending,
        'isRejected': isRejected,
        'isCompleted': isCompleted,
        'rejectReason': rejectReason,
      }),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 302) {
        print('the task updated');
        setState(() {
          widget.taskData["isPending"] = isPending;
          widget.taskData["isRejected"] = isRejected;
          widget.taskData["isCompleted"] = isCompleted;
          widget.taskData["rejectReason"] = rejectReason;
        });
      } else {
        print('Failed to update task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error $e');
    }
  }

  Future taskCompleted(int isPending, int isRejected, int isCompleted) async {
    final taskId = widget.taskData["id"];
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/v1/tasks/$taskId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, int>{
        'isPending': isPending,
        'isRejected': isRejected,
        'isCompleted': isCompleted,
      }),
    );
    try {
      if (response.statusCode == 200 || response.statusCode == 302) {
        print('the task updated');
        setState(() {
          widget.taskData["isPending"] = isPending;
          widget.taskData["isRejected"] = isRejected;
          widget.taskData["isCompleted"] = isCompleted;
        });
      } else {
        print('Failed to update task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('error $e');
    }
  }
}
