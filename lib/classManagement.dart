import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Department.dart';
import 'package:tp7_flutter/DepartmentService.dart';

class ClassManagement extends StatefulWidget {
  const ClassManagement({Key? key}) : super(key: key);

  @override
  _ClassManagementState createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  List<Classe> _classes = [];
  List<Department> _departments = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _studentCountController = TextEditingController();
  Department? _selectedDepartment;

  final String baseUrl = "http://10.0.2.2:8095";
  bool _isAddingOrEditing = false;
  Classe? _editingClass;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([_loadDepartments(), _loadClasses()]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDepartments() async {
    try {
      print('🔄 Tentative de chargement des départements...');
      print('📡 URL: ${DepartmentService.baseUrl}');

      _departments = await DepartmentService.getDepartments();

      print('✅ SUCCÈS: ${_departments.length} départements chargés');

      if (_departments.isEmpty) {
        print('⚠️  Liste des départements vide');
      } else {
        _departments.forEach((dept) {
          print('   - ${dept.nomDept} (ID: ${dept.codDept})');
        });
      }
    } catch (e) {
      print('❌ ERREUR lors du chargement des départements: $e');
      // Ajoutez des données mockées en cas d'erreur
      _departments = _getMockDepartments();
      print(
        '🔄 Utilisation de données mockées: ${_departments.length} départements',
      );
    }
  }

  // Méthode pour les données mockées temporaires
  List<Department> _getMockDepartments() {
    return [
      Department(codDept: 1, nomDept: "Informatique"),
      Department(codDept: 2, nomDept: "Gestion"),
      Department(codDept: 3, nomDept: "Mécanique"),
    ];
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classes'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _classes = data.map((item) => Classe.fromMap(item)).toList();
        });
      }
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate() && _selectedDepartment != null) {
      setState(() {
        _isAddingOrEditing = true;
      });

      try {
        // FORMAT CORRECT POUR LE BACKEND
        Map<String, dynamic> classeData = {
          'nomClass': _classNameController.text,
          'nbreEtud': int.parse(_studentCountController.text),
          'department': {'codDept': _selectedDepartment!.codDept},
        };

        // Ajouter l'ID si on est en mode édition
        if (_editingClass != null) {
          classeData['codClass'] = _editingClass!.codClass;
        }

        print('📤 Données envoyées: $classeData');

        final uri = _editingClass == null
            ? Uri.parse('$baseUrl/classes')
            : Uri.parse('$baseUrl/classes/${_editingClass!.codClass}');

        final response = await (_editingClass == null
            ? http.post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode(classeData),
              )
            : http.put(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: json.encode(classeData),
              ));

        print('📥 Réponse reçue - Status: ${response.statusCode}');
        print('📥 Body: ${response.body}');

        if (response.statusCode == 200) {
          _resetForm();
          Navigator.pop(context);
          await _loadClasses();
          _showSuccessMessage();
        } else {
          _showErrorMessage(
            'Erreur serveur: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        _showErrorMessage('Erreur réseau: $e');
      } finally {
        setState(() {
          _isAddingOrEditing = false;
        });
      }
    } else if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un département'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _resetForm() {
    _classNameController.clear();
    _studentCountController.clear();
    _selectedDepartment = null;
    _editingClass = null;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingClass == null
              ? 'Classe ajoutée avec succès'
              : 'Classe modifiée avec succès',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _deleteClass(int classId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/classes/$classId'),
      );
      if (response.statusCode == 200) {
        await _loadClasses();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Classe supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la suppression: $e');
    }
  }

  void _showAddOrEditClassDialog({Classe? classe}) {
    _editingClass = classe;
    _classNameController.text = classe?.nomClass ?? '';
    _studentCountController.text = classe?.nbreEtud.toString() ?? '';

    // Pré-sélectionner le département si en mode édition
    Department? initialDepartment;
    if (classe != null && classe.department != null) {
      initialDepartment = _departments.firstWhere(
        (dept) => dept.codDept == classe.department!.codDept,
        orElse: () => _departments.isNotEmpty
            ? _departments.first
            : Department(codDept: 0, nomDept: ''),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Utiliser une variable locale pour gérer l'état du dropdown
        Department? selectedDepartment = initialDepartment;

        return AlertDialog(
          title: Text(
            classe == null ? "Ajouter une classe" : "Modifier la classe",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown pour sélectionner le département
                  DropdownButtonFormField<Department>(
                    value: selectedDepartment,
                    decoration: InputDecoration(
                      labelText: 'Département',
                      border: OutlineInputBorder(),
                    ),
                    items: _departments.map((Department department) {
                      return DropdownMenuItem<Department>(
                        value: department,
                        child: Text(department.nomDept),
                      );
                    }).toList(),
                    onChanged: (Department? newValue) {
                      selectedDepartment = newValue;
                      // Mettre à jour l'état parent
                      _selectedDepartment = newValue;
                    },
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner un département'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _classNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom de la classe',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer le nom de la classe'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _studentCountController,
                    decoration: InputDecoration(
                      labelText: 'Nombre d\'étudiants',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer le nombre d\'étudiants';
                      if (int.tryParse(value) == null)
                        return 'Veuillez entrer un nombre valide';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetForm();
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isAddingOrEditing
                  ? null
                  : () {
                      // S'assurer que le département sélectionné est sauvegardé
                      _selectedDepartment = selectedDepartment;
                      _saveClass();
                    },
              child: _isAddingOrEditing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(classe == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Classe classe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text(
            "Êtes-vous sûr de vouloir supprimer la classe ${classe.nomClass} ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteClass(classe.codClass!);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Classes'),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildClassList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditClassDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildClassList() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Classes',
                _classes.length.toString(),
                Icons.school,
                Colors.blue,
              ),
              _buildStatCard(
                'Total Étudiants',
                _classes.fold(0, (sum, c) => sum + c.nbreEtud).toString(),
                Icons.people,
                Colors.green,
              ),
            ],
          ),
        ),
        Expanded(
          child: _classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        "Aucune classe disponible",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final classe = _classes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.school, color: Colors.blue[800]),
                        ),
                        title: Text(
                          classe.nomClass,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${classe.nbreEtud} étudiants'),
                            if (classe.department != null)
                              Text(
                                'Département: ${classe.department!.nomDept}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () =>
                                  _showAddOrEditClassDialog(classe: classe),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(classe),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }
}
