// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:task_creator/data.dart';
import 'package:task_creator/screens/Manager/employee_details_screen.dart';
import 'package:task_creator/screens/Manager/employee_form_dialoge.dart';
import 'package:task_creator/screens/Manager/login_screen.dart';
import 'package:task_creator/screens/task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  Map<String, dynamic>? managerData;
  Map<String, dynamic>? employeeData;
  HomeScreen(
    this.managerData,
    this.employeeData, {
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    fetchDataForEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4a171e),
      appBar: AppBar(
        backgroundColor: const Color(0xff4a171e),
        elevation: 0,
        centerTitle: true,
        title: Text(
          (widget.managerData != null)
              ? "Hello, ${widget.managerData!['name']}"
              : "Hello, ${widget.employeeData!['name']}",
          style: const TextStyle(
            color: Color(0xffffc23c),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                logOut(context);
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              widget.employeeData == null ? 'My Employees' : "My Tasks",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xffffc23c),
              ),
            ),
          ),
          const SizedBox(
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 45),
            child: RefreshIndicator(
              onRefresh: widget.employeeData == null
                  ? handleRefreshManager
                  : handleRefreshEmployee,
              child: ListView.builder(
                itemCount: widget.employeeData == null
                    ? widget.managerData!["employees"].length
                    : widget.employeeData!["tasks"].length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xfffff3cd),
                    child: ListTile(
                      title: Text(
                        widget.employeeData == null
                            ? widget.managerData!["employees"][index]["name"]
                                .toString()
                            : widget.employeeData!["tasks"][index]["title"]
                                .toString(),
                        style: const TextStyle(
                          color: Color(0xffffc23c),
                        ),
                      ),
                      subtitle: Text(
                        widget.employeeData == null
                            ? widget.managerData!["employees"][index]['email']
                                .toString()
                            : widget.employeeData!['tasks'][index]
                                    ['description']
                                .toString(),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.employeeData == null
                                  ? EmployeeDetailsScreen(
                                      employeeData: widget
                                          .managerData!["employees"][index],
                                    )
                                  : TaskDetailsScreen(
                                      taskData: widget.employeeData!["tasks"]
                                          [index]),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: widget.employeeData == null
          ? Drawer(
              backgroundColor: const Color(0xff4a171e),
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xffffc23c),
                    ),
                    child: UserAccountsDrawerHeader(
                      margin: const EdgeInsets.all(0),
                      decoration: const BoxDecoration(color: Color(0xffffc23c)),
                      accountName: Text(
                        "${widget.managerData!['name']}",
                        style: const TextStyle(
                            color: Color(0xff4a171e), fontSize: 20),
                      ),
                      accountEmail: Text(
                        "${widget.managerData!['email']}",
                        style: const TextStyle(
                            color: Color(0xff4a171e), fontSize: 17),
                      ),
                      currentAccountPictureSize: const Size.square(50),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: const Color(0xff4a171e),
                        child: Text(
                          widget.managerData!['name'][0],
                          style: const TextStyle(
                              fontSize: 30.0, color: Color(0xffffc23c)),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Color(0xffffc23c),
                    ),
                    title: const Text(
                      'Add Employee',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xffffc23c),
                      ),
                    ),
                    onTap: () {
                      _showCreateEmployeeDialog();
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Future<void> handleRefreshEmployee() async {
    final employeeId = widget.employeeData!['id'];
    http
        .get(Uri.parse('http://10.0.2.2:8000/api/v1/employees/$employeeId'))
        .then((response) {
      if (response.statusCode == 200) {
        final updatedEmployeeData = json.decode(response.body);
        setState(() {
          widget.employeeData = updatedEmployeeData;
        });
      } else {
        print('Failed to refresh screen. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error refreshing screen: $error');
    });
  }

  Future<void> handleRefreshManager() async {
    final managerId = widget.managerData!['id'];
    http
        .get(Uri.parse('http://10.0.2.2:8000/api/v1/managers/$managerId'))
        .then((response) {
      if (response.statusCode == 200) {
        final updatedManagerData = json.decode(response.body);
        setState(() {
          widget.managerData = updatedManagerData;
        });
      } else {
        print('Failed to refresh screen. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error refreshing screen: $error');
    });
  }

  void logOut(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void createEmployee(
      String managerId, String name, String email, String password) async {
    final Map<String, dynamic> requestBody = {
      'managerId': managerId,
      'name': name,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/v1/employees'),
      body: requestBody,
    );

    if (response.statusCode == 201) {
      print('Employee created successfully');
    } else {
      print('Failed to create employee. Status code: ${response.statusCode}');
    }
  }

  void _showCreateEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String email = '';
        String password = '';

        return AlertDialog(
          title: const Text('Create New Employee'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
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
                createEmployee(widget.managerData!['id'].toString(), name,
                    email, password);
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void openUserDetailsModal(Map<String, dynamic> managerData) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      backgroundColor: const Color(0xffffc23c),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Employee Details",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4a171e),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                'Name: ${managerData["name"]}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xff4a171e),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${managerData["email"]}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xff4a171e),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Tasks",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4a171e),
                    ),
                  ),
                ],
              ),
              if (managerData["tasks"] != null)
                for (var task in managerData["tasks"])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Title: ${task["title"]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xff4a171e),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Task Description: ${task["description"]}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xff4a171e),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }
}
