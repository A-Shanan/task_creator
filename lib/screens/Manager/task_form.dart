// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskForm extends StatefulWidget {
  final int employeeId;

  const TaskForm({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController isPendingController = TextEditingController(text: '1');
  TextEditingController isCompletedController =
      TextEditingController(text: '0');
  TextEditingController isRejectedController = TextEditingController(text: '0');
  TextEditingController rejectReasonController =
      TextEditingController(text: "    ");

  void submit() async {
    final taskTitle = titleController.value.text;
    final taskDescription = descriptionController.value.text;
    final taskIsPending = isPendingController.value.text;
    final taskIsCompleted = isCompletedController.value.text;
    final taskIsRejected = isRejectedController.value.text;
    final taskRejectReason = rejectReasonController.value.text;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/v1/tasks'),
      body: {
        'employeeId': widget.employeeId.toString(),
        'title': taskTitle,
        'description': taskDescription,
        'isPending': taskIsPending,
        'isCompleted': taskIsCompleted,
        'isRejected': taskIsRejected,
        'rejectReason': taskRejectReason,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 302) {
      setState(() {
        Navigator.of(context).pop();
      });
    } else {
      print('error:     ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Task title'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Task description'),
          ),
          ElevatedButton(
            onPressed: submit,
            child: Text('Add task'),
          ),
        ],
      ),
    );
  }
}
