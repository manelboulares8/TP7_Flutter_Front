// api_service.dart
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Etudiant.dart';
import 'dart:convert';

import 'package:tp7_flutter/Formation.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8081";

  static Future<List<Classe>> getClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classes'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Classe.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load classes');
    }
  }

  static Future<List<Etudiant>> getStudentsByClass(Long classId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/etudiants/search/findByClasseCodClass?codClass=$classId',
      ),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> studentsData = data['_embedded']['etudiants'];
      return studentsData.map((item) => Etudiant.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  static Future<List<Formation>> getFormations() async {
    final response = await http.get(Uri.parse('$baseUrl/formations'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Formation.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load formations');
    }
  }
}
