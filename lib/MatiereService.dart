import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Matiere.dart';

class MatiereService {
  static const String baseUrl = 'http://10.0.2.2:8095/matieres';

  static Future<List<Matiere>> getMatieres() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((matiere) => Matiere.fromMap(matiere)).toList();
      } else {
        throw Exception('Failed to load matieres');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Matiere> getMatiereById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Matiere.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to load matiere');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Matiere> createMatiere(Matiere matiere) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(matiere.toMap()),
      );
      if (response.statusCode == 200) {
        return Matiere.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create matiere');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Matiere> updateMatiere(Matiere matiere) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${matiere.codMat}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(matiere.toMap()),
      );
      if (response.statusCode == 200) {
        return Matiere.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to update matiere');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteMatiere(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete matiere');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Matiere>> getMatieresByClass(int classId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classe/$classId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((matiere) => Matiere.fromMap(matiere)).toList();
      } else {
        throw Exception('Failed to load matieres for class');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
