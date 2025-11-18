// absence_screen.dart
import 'package:flutter/material.dart';
import 'package:tp7_flutter/Absence.dart';
import 'package:tp7_flutter/AbsenceService.dart';
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Department.dart';
import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Matiere.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  List<Department> departments = [];
  List<Classe> classes = [];
  List<Etudiant> students = [];
  List<Matiere> matieres = [];
  List<Absence> absences = [];

  Department? selectedDepartment;
  Classe? selectedClass;
  Etudiant? selectedStudent;
  Matiere? selectedMatiere;

  TextEditingController dateController = TextEditingController();
  TextEditingController nhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    try {
      departments = await AbsenceService.getDepartments();
      setState(() {});
    } catch (e) {
      print('Error loading departments: $e');
    }
  }

  Future<void> loadClasses(int deptId) async {
    try {
      classes = await AbsenceService.getClassesByDepartment(deptId);
      selectedClass = null;
      selectedStudent = null;
      selectedMatiere = null;
      students.clear();
      matieres.clear();
      absences.clear();
      setState(() {});
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> loadStudents(int classId) async {
    try {
      students = await AbsenceService.getStudentsByClass(classId);
      matieres = await AbsenceService.getMatieresByClass(classId);
      selectedStudent = null;
      selectedMatiere = null;
      absences.clear();
      setState(() {});
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> loadAbsences(int studentId) async {
    try {
      absences = await AbsenceService.getAbsencesByStudent(studentId);
      setState(() {});
    } catch (e) {
      print('Error loading absences: $e');
    }
  }

  Future<void> addAbsence() async {
    if (selectedStudent == null ||
        selectedMatiere == null ||
        dateController.text.isEmpty ||
        nhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      Absence newAbsence = Absence(
        etudiantId: selectedStudent!.id!,
        matiereId: selectedMatiere!.codMat!,
        dateA: DateTime.parse(dateController.text),
        nha: int.parse(nhaController.text),
      );

      await AbsenceService.addAbsence(newAbsence);
      await loadAbsences(selectedStudent!.id!);

      // Reset form
      dateController.clear();
      nhaController.clear();
      selectedMatiere = null;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Absence ajoutée avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout: $e')));
    }
  }

  Future<void> deleteAbsence(int absenceId) async {
    try {
      await AbsenceService.deleteAbsence(absenceId);
      await loadAbsences(selectedStudent!.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Absence supprimée avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  void editAbsence(Absence absence) {
    selectedMatiere = matieres.firstWhere((m) => m.codMat == absence.matiereId);
    dateController.text = absence.dateA.toIso8601String().split('T')[0];
    nhaController.text = absence.nha.toString();

    // Remove the absence to be edited
    deleteAbsence(absence.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Department>(
                value: selectedDepartment,
                decoration: InputDecoration(labelText: 'Département'),
                items: departments.map((Department dept) {
                  return DropdownMenuItem<Department>(
                    value: dept,
                    child: Text(dept.nomDept),
                  );
                }).toList(),
                onChanged: (Department? newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                    if (newValue != null) {
                      loadClasses(newValue.codDept!);
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<Classe>(
                value: selectedClass,
                decoration: InputDecoration(labelText: 'Classe'),
                items: classes.map((Classe classe) {
                  return DropdownMenuItem<Classe>(
                    value: classe,
                    child: Text(classe.nomClass),
                  );
                }).toList(),
                onChanged: (Classe? newValue) {
                  setState(() {
                    selectedClass = newValue;
                    if (newValue != null) {
                      loadStudents(newValue.codClass!);
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<Etudiant>(
                value: selectedStudent,
                decoration: InputDecoration(labelText: 'Étudiant'),
                items: students.map((Etudiant student) {
                  return DropdownMenuItem<Etudiant>(
                    value: student,
                    child: Text('${student.nom} ${student.prenom}'),
                  );
                }).toList(),
                onChanged: (Etudiant? newValue) {
                  setState(() {
                    selectedStudent = newValue;
                    if (newValue != null) {
                      loadAbsences(newValue.id!);
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              if (selectedStudent != null) ...[
                Text(
                  'Étudiant sélectionné:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Nom: ${selectedStudent!.nom}'),
                Text('Prénom: ${selectedStudent!.prenom}'),
                SizedBox(height: 16),
              ],

              Text(
                'Ajouter une absence:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<Matiere>(
                value: selectedMatiere,
                decoration: InputDecoration(labelText: 'Matière'),
                items: matieres.map((Matiere matiere) {
                  return DropdownMenuItem<Matiere>(
                    value: matiere,
                    child: Text(matiere.intMat),
                  );
                }).toList(),
                onChanged: (Matiere? newValue) {
                  setState(() {
                    selectedMatiere = newValue;
                  });
                },
              ),

              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    dateController.text = pickedDate.toIso8601String().split(
                      'T',
                    )[0];
                  }
                },
              ),

              TextFormField(
                controller: nhaController,
                decoration: InputDecoration(
                  labelText: 'Nombre d\'heures absentes',
                ),
                keyboardType: TextInputType.number,
              ),

              ElevatedButton(
                onPressed: addAbsence,
                child: Text('Ajouter Absence'),
              ),

              SizedBox(height: 16),

              Text(
                'Liste des absences:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              // 🎯 LISTER LES ABSENCES SANS EXPANDED → SHRINKWRAP
              ListView.builder(
                shrinkWrap: true, // Important
                physics:
                    NeverScrollableScrollPhysics(), // empêche scroll interne
                itemCount: absences.length,
                itemBuilder: (context, index) {
                  Absence absence = absences[index];
                  return Card(
                    child: ListTile(
                      title: Text(absence.matiere?.intMat ?? 'Matière'),
                      subtitle: Text(
                        'Date: ${absence.dateA.toLocal().toString().split(' ')[0]}, '
                        'Heures: ${absence.nha}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editAbsence(absence),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAbsence(absence.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
