// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchDataForManagers() async {
  var url = Uri.parse('http://10.0.2.2:8000/api/v1/managers');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    print("Response for Managers: $data");
    return data;
  } else {
    print('error: ${response.statusCode}');
    return [];
  }
}

Future<List<dynamic>> fetchDataForEmployees() async {
  var url = Uri.parse('http://10.0.2.2:8000/api/v1/employees');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    print("Response for Employeess: $data");
    return data;
  } else {
    print('error: ${response.statusCode}');
    return [];
  }
}
