import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Note.dart';

class NoteService {
  static const String baseUrl = 'http://10.0.2.2:8095/api/notes';

  static Future<List<Note>> getNotes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((note) => Note.fromMap(note)).toList();
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Note>> getNotesByEtudiant(int etudiantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiant/$etudiantId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((note) => Note.fromMap(note)).toList();
      } else {
        throw Exception('Failed to load notes for student');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Note>> getNotesByMatiere(int matiereId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matiere/$matiereId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((note) => Note.fromMap(note)).toList();
      } else {
        throw Exception('Failed to load notes for subject');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Note> addNote(Note note) async {
    try {
      final noteData = note.toMap();
      print('📤 Données note: $noteData');

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(noteData),
          )
          .timeout(Duration(seconds: 10));

      print('📥 Réponse - Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return Note(
          id: responseData['id'],
          etudiantId: note.etudiantId,
          matiereId: note.matiereId,
          valeurNote: responseData['valeurNote']?.toDouble() ?? note.valeurNote,
        );
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<Note> updateNote(Note note) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${note.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'valeurNote': note.valeurNote}),
      );

      if (response.statusCode == 200) {
        return Note.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
