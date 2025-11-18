// student_management.dart
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Formation.dart';
import 'package:tp7_flutter/User.dart';

class StudentManagement extends StatefulWidget {
  final User user;

  const StudentManagement({Key? key, required this.user}) : super(key: key);

  @override
  _StudentManagementState createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  List<Classe> _classes = [];
  List<Etudiant> _students = [];
  Classe? _selectedClass;
  bool _isLoading = true;

  final String baseUrl = "http://10.0.2.2:8095";

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classes'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _classes = data.map((item) => Classe.fromMap(item)).toList();
          if (_classes.isNotEmpty) {
            _selectedClass = _classes.first;
            _loadStudentsByClass(_classes.first.codClass! as int);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading classes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentsByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiants/classe/$classId'),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        print('Réponse API: $body'); // 👀 pour debug

        final List<dynamic> jsonData = json.decode(body);

        setState(() {
          _students = jsonData
              .where((item) => item != null)
              .map((item) => Etudiant.fromMap(item as Map<String, dynamic>))
              .toList();
        });

        print('Étudiants chargés: ${_students.length}');
      } else {
        print('Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erreur lors du chargement des étudiants: $e');
    }
  }

  void _onClassChanged(Classe? newClass) {
    if (newClass != null) {
      setState(() {
        _selectedClass = newClass;
      });
      _loadStudentsByClass(newClass.codClass! as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown pour sélectionner la classe
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Text(
                        "Classe: ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<Classe>(
                          value: _selectedClass,
                          isExpanded: true,
                          items: _classes.map((Classe classe) {
                            return DropdownMenuItem<Classe>(
                              value: classe,
                              child: Text(classe.nomClass),
                            );
                          }).toList(),
                          onChanged: _onClassChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? Center(
                          child: Text(
                            "Aucun étudiant dans cette classe",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(student.prenom[0]),
                                ),
                                title: Text(
                                  '${student.prenom} ${student.nom}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Formation: ${student.formation?.nom}',
                                  style: GoogleFonts.poppins(),
                                ),
                                trailing: Text(
                                  '${student.dateNais.day}/${student.dateNais.month}/${student.dateNais.year}',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStudentDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  void _showAddStudentDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nomController = TextEditingController();
    final TextEditingController _prenomController = TextEditingController();
    DateTime? _selectedDate;
    Classe? _selectedClass = _classes.isNotEmpty ? _classes.first : null;
    Formation? _selectedFormation;
    List<Formation> _formations = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un étudiant'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              // Charger les formations si la liste est vide
              if (_formations.isEmpty) {
                http
                    .get(Uri.parse('$baseUrl/formations'))
                    .then((response) {
                      if (response.statusCode == 200) {
                        final List<dynamic> data = json.decode(response.body);
                        final loadedFormations = data
                            .map((item) => Formation.fromMap(item))
                            .toList();
                        setStateDialog(() {
                          _formations = loadedFormations;
                          if (_formations.isNotEmpty) {
                            _selectedFormation = _formations.first;
                          }
                        });
                      }
                    })
                    .catchError((e) {
                      print('Erreur lors du chargement des formations: $e');
                    });
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(labelText: 'Nom'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer le nom'
                            : null,
                      ),
                      TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(labelText: 'Prénom'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer le prénom'
                            : null,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Date de naissance'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: Text('Choisir'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      DropdownButton<Classe>(
                        value: _selectedClass,
                        isExpanded: true,
                        hint: Text('Sélectionner une classe'),
                        items: _classes.map((classe) {
                          return DropdownMenuItem<Classe>(
                            value: classe,
                            child: Text(classe.nomClass),
                          );
                        }).toList(),
                        onChanged: (newClass) {
                          setStateDialog(() {
                            _selectedClass = newClass;
                          });
                        },
                      ),
                     
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    _selectedDate != null &&
                    _selectedClass != null &&
                    _selectedFormation != null) {
                  final newStudent = {
                    'nom': _nomController.text,
                    'prenom': _prenomController.text,
                    'dateNais': _selectedDate!.toIso8601String(),
                    'classe': {'codClass': _selectedClass!.codClass},
                    'formation': {'id': _selectedFormation!.id},
                  };

                  try {
                    final response = await http.post(
                      Uri.parse('$baseUrl/etudiants'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(newStudent),
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      Navigator.of(context).pop(); // fermer le dialogue
                      _loadStudentsByClass(
                        _selectedClass!.codClass!,
                      ); // recharger la liste
                    } else {
                      print(
                        'Erreur lors de la création: ${response.statusCode}',
                      );
                    }
                  } catch (e) {
                    print('Erreur lors de la requête: $e');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
