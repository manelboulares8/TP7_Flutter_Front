// absence_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Absence.dart';
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Department.dart';
import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Matiere.dart';

class AbsenceService {
  static const String baseUrl = 'http://10.0.2.2:8095/api/absences';

  static Future<List<Department>> getDepartments() async {
    final response = await http.get(Uri.parse('$baseUrl/departments'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((dept) => Department.fromMap(dept)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  static Future<List<Classe>> getClassesByDepartment(int deptId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/departments/$deptId/classes'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((classe) => Classe.fromMap(classe)).toList();
    } else {
      throw Exception('Failed to load classes');
    }
  }

  static Future<List<Etudiant>> getStudentsByClass(int classId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/$classId/students'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((student) => Etudiant.fromMap(student)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  static Future<List<Matiere>> getMatieresByClass(int classId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/$classId/matieres'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((matiere) => Matiere.fromMap(matiere)).toList();
    } else {
      throw Exception('Failed to load matieres');
    }
  }

  static Future<List<Absence>> getAbsencesByStudent(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId/absences'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((absence) => Absence.fromMap(absence)).toList();
    } else {
      throw Exception('Failed to load absences');
    }
  }

  static Future<Absence> addAbsence(Absence absence) async {
    try {
      Map<String, dynamic> absenceData = {
        "etudiant": {"id": absence.etudiantId},
        "matiere": {"codMat": absence.matiereId},
        "dateA": absence.dateA.toIso8601String().split('T')[0],
        "nha": absence.nha,
      };

      print('📤 JSON envoyé: ${json.encode(absenceData)}');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(absenceData),
          )
          .timeout(Duration(seconds: 10));

      print('📥 Réponse - Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        // La réponse ne contient que l'ID, date et nha
        // On crée une absence avec les données de base + les IDs qu'on avait déjà
        Map<String, dynamic> responseData = json.decode(response.body);

        Absence createdAbsence = Absence(
          id: responseData['id'],
          etudiantId: absence.etudiantId, // Garde l'ID original
          matiereId: absence.matiereId, // Garde l'ID original
          dateA: DateTime.parse(responseData['dateA']),
          nha: responseData['nha'],
        );

        print('✅ Absence créée: $createdAbsence');
        return createdAbsence;
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur complète: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<void> deleteAbsence(int absenceId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$absenceId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete absence');
    }
  }

  static Future<Absence> updateAbsence(Absence absence) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${absence.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(absence.toMap()),
    );
    if (response.statusCode == 200) {
      return Absence.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to update absence');
    }
  }
}
