import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tp7_flutter/AbsenceService.dart';
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Department.dart';
import 'package:tp7_flutter/DepartmentService.dart';
import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Matiere.dart';
import 'package:tp7_flutter/Note.dart';
import 'package:tp7_flutter/noteService.dart';

class NoteManagement extends StatefulWidget {
  const NoteManagement({Key? key}) : super(key: key);

  @override
  _NoteManagementState createState() => _NoteManagementState();
}

class _NoteManagementState extends State<NoteManagement> {
  List<Note> _notes = [];
  List<Department> _departments = [];
  List<Classe> _classes = [];
  List<Etudiant> _students = [];
  List<Matiere> _matieres = [];

  Department? _selectedDepartment;
  Classe? _selectedClass;
  Etudiant? _selectedStudent;
  Matiere? _selectedMatiere;

  bool _isLoading = true;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      _departments = await DepartmentService.getDepartments();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadClasses(int deptId) async {
    try {
      _classes = await DepartmentService.getClassesByDepartment(deptId);
      _selectedClass = null;
      _selectedStudent = null;
      _students.clear();
      _matieres.clear();
      _notes.clear();
      setState(() {});
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadStudents(int classId) async {
    try {
      _students = await AbsenceService.getStudentsByClass(classId);
      _matieres = await AbsenceService.getMatieresByClass(classId);
      _selectedStudent = null;
      _selectedMatiere = null;
      _notes.clear();
      setState(() {});
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _loadNotes(int studentId) async {
    try {
      _notes = await NoteService.getNotesByEtudiant(studentId);
      setState(() {
        _showNotes = true;
      });
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  void _showAddNoteDialog() {
    final _formKey = GlobalKey<FormState>();
    final _noteController = TextEditingController();
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une note'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Matiere>(
                  value: _selectedMatiere,
                  decoration: InputDecoration(labelText: 'Matière'),
                  items: _matieres.map((Matiere matiere) {
                    return DropdownMenuItem<Matiere>(
                      value: matiere,
                      child: Text(matiere.intMat),
                    );
                  }).toList(),
                  onChanged: (Matiere? newValue) {
                    setState(() {
                      _selectedMatiere = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Sélectionnez une matière' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Entrez une note';
                    final note = double.tryParse(value);
                    if (note == null) return 'Note invalide';
                    if (note < 0 || note > 20) return 'Note entre 0 et 20';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedMatiere != null) {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          Note newNote = Note(
                            etudiantId: _selectedStudent!.id!,
                            matiereId: _selectedMatiere!.codMat!,
                            valeurNote: double.parse(_noteController.text),
                          );

                          await NoteService.addNote(newNote);
                          Navigator.pop(context);
                          await _loadNotes(_selectedStudent!.id!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Note ajoutée avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: _isSaving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(int noteId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await NoteService.deleteNote(noteId);
        await _loadNotes(_selectedStudent!.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Notes'),
        backgroundColor: Colors.orange[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Sélection du département
                  DropdownButtonFormField<Department>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(labelText: 'Département'),
                    items: _departments.map((Department dept) {
                      return DropdownMenuItem<Department>(
                        value: dept,
                        child: Text(dept.nomDept),
                      );
                    }).toList(),
                    onChanged: (Department? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                        if (newValue != null) {
                          _loadClasses(newValue.codDept!);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Sélection de la classe
                  DropdownButtonFormField<Classe>(
                    value: _selectedClass,
                    decoration: InputDecoration(labelText: 'Classe'),
                    items: _classes.map((Classe classe) {
                      return DropdownMenuItem<Classe>(
                        value: classe,
                        child: Text(classe.nomClass),
                      );
                    }).toList(),
                    onChanged: (Classe? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        if (newValue != null) {
                          _loadStudents(newValue.codClass!);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Sélection de l'étudiant
                  DropdownButtonFormField<Etudiant>(
                    value: _selectedStudent,
                    decoration: InputDecoration(labelText: 'Étudiant'),
                    items: _students.map((Etudiant student) {
                      return DropdownMenuItem<Etudiant>(
                        value: student,
                        child: Text('${student.nom} ${student.prenom}'),
                      );
                    }).toList(),
                    onChanged: (Etudiant? newValue) {
                      setState(() {
                        _selectedStudent = newValue;
                        if (newValue != null) {
                          _loadNotes(newValue.id!);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Bouton pour ajouter une note
                  if (_selectedStudent != null)
                    ElevatedButton.icon(
                      onPressed: _showAddNoteDialog,
                      icon: Icon(Icons.add),
                      label: Text('Ajouter une note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                      ),
                    ),

                  SizedBox(height: 16),

                  // Liste des notes
                  if (_showNotes) ...[
                    Text(
                      'Notes de ${_selectedStudent?.nom} ${_selectedStudent?.prenom}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: _notes.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune note pour cet étudiant',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _notes.length,
                              itemBuilder: (context, index) {
                                final note = _notes[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getNoteColor(
                                        note.valeurNote,
                                      ),
                                      child: Text(
                                        note.valeurNote.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      'Matière: ${_getMatiereName(note.matiereId)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Note: ${note.valeurNote.toStringAsFixed(2)}/20',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteNote(note.id!),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Color _getNoteColor(double note) {
    if (note >= 16) return Colors.green;
    if (note >= 14) return Colors.lightGreen;
    if (note >= 12) return Colors.orange;
    if (note >= 10) return Colors.amber;
    return Colors.red;
  }

  String _getMatiereName(int? matiereId) {
    if (matiereId == null) return 'Inconnue';
    final matiere = _matieres.firstWhere(
      (m) => m.codMat == matiereId,
      orElse: () => Matiere(codMat: 0, intMat: 'Inconnue', description: ''),
    );
    return matiere.intMat;
  }
}
