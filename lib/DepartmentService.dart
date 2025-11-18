// department_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Department.dart';

class DepartmentService {
  static const String baseUrl = 'http://10.0.2.2:8095/api/departments';

  static Future<List<Department>> getDepartments() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((dept) => Department.fromMap(dept)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  static Future<Department> getDepartmentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Department.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to load department');
    }
  }

  static Future<Department> createDepartment(Department department) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toMap()),
    );
    if (response.statusCode == 200) {
      return Department.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create department');
    }
  }

  static Future<Department> updateDepartment(Department department) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${department.codDept}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toMap()),
    );
    if (response.statusCode == 200) {
      return Department.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to update department');
    }
  }

  static Future<void> deleteDepartment(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete department');
    }
  }

  static Future<List<Classe>> getClassesByDepartment(int deptId) async {
    final response = await http.get(Uri.parse('$baseUrl/$deptId/classes'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((classe) => Classe.fromMap(classe)).toList();
    } else {
      throw Exception('Failed to load classes for department');
    }
  }
}
