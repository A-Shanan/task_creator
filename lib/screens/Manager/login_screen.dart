// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:task_creator/data.dart';
import 'package:task_creator/screens/Manager/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    fetchAndStoreDataForManager();
    fetchAndStoreDataForEmployee();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> apiData = [];

  List<dynamic> managerEmails = [];
  List managerPasswords = [];
  bool isPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Text(
                    'taskie'.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 45.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'Login',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 45,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 17),
                    textAlignVertical: TextAlignVertical.center,
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      prefixIcon: const Icon(
                        Icons.person_2_outlined,
                        size: 30,
                        color: Color.fromARGB(133, 0, 0, 0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0.5, color: Color.fromARGB(70, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0.5, color: Color.fromARGB(70, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      hintText: 'Email',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 30,
                        color: Color.fromARGB(133, 0, 0, 0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isPassword = !isPassword;
                          });
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0.5, color: Color.fromARGB(70, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 0.5, color: Color.fromARGB(70, 0, 0, 0)),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      hintText: 'Password',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                    obscuringCharacter: "★",
                    obscureText: isPassword,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forget your PASSOWRD?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(133, 0, 0, 0),
                            ),
                          ))
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleLoginEmployee(context);
                      handleLogin(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> login(String email, String password) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/v1/managers');
    var response =
        await http.post(url, body: {'email': email, 'password': password});

    if (response.statusCode == 200 || response.statusCode == 302) {
      print("Response11111111: ${response.body}");
      return true;
    } else {
      print('error222: ${response.statusCode}');
      return false;
    }
  }

  Future<void> fetchAndStoreDataForManager() async {
    try {
      final data = await fetchDataForManagers();
      setState(() {
        apiData = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchAndStoreDataForEmployee() async {
    try {
      final data = await fetchDataForEmployees();
      setState(() {
        apiData = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>?> loginManager(
      String enteredEmail, String enteredPassword) async {
    final apiUrl = 'http://10.0.2.2:8000/api/v1/managers';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> managersData = json.decode(response.body);
      final managerData = managersData.firstWhere(
        (manager) =>
            manager['email'] == enteredEmail &&
            manager['password'] == enteredPassword,
        orElse: () => null,
      );
      return managerData;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    final enteredEmail = emailController.text;
    final enteredPassword = passwordController.text;

    final userData = await loginManager(enteredEmail, enteredPassword);

    if (userData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userData, null),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid email or password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> loginEmployee(
      String enteredEmail, String enteredPassword) async {
    final apiUrl = 'http://10.0.2.2:8000/api/v1/employees';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> employeesData = json.decode(response.body);
      final employeeData = employeesData.firstWhere(
        (employee) =>
            employee['email'] == enteredEmail &&
            employee['password'] == enteredPassword,
        orElse: () => null,
      );
      return employeeData;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> handleLoginEmployee(BuildContext context) async {
    final enteredEmail = emailController.text;
    final enteredPassword = passwordController.text;

    final employeesData = await loginEmployee(enteredEmail, enteredPassword);

    if (employeesData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(null, employeesData),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid email or password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
