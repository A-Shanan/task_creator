import 'package:flutter/material.dart';

class EmployeeFormDialog extends StatelessWidget {
  final void Function(String, String, String) onCreate;

  const EmployeeFormDialog({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text('Create Employee'),
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final name = nameController.text;
            final email = emailController.text;
            final password = passwordController.text;
            onCreate(name, email, password);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
