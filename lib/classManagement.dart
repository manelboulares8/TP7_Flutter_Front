// class_management.dart
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/User.dart';

class ClassManagement extends StatefulWidget {
  final User user;

  const ClassManagement({Key? key, required this.user}) : super(key: key);

  @override
  _ClassManagementState createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  List<Classe> _classes = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _studentCountController = TextEditingController();

  final String baseUrl = "http://10.0.2.2:8095";
  bool _isAddingOrEditing = false;
  Classe? _editingClass;

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

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingOrEditing = true;
      });

      try {
        final classe = Classe(
          nomClass: _classNameController.text,
          nbreEtud: int.parse(_studentCountController.text),
          codClass: _editingClass?.codClass,
        );

        final uri = _editingClass == null
            ? Uri.parse('$baseUrl/classes')
            : Uri.parse('$baseUrl/classes/${_editingClass!.codClass}');

        final response = await (_editingClass == null
            ? http.post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(classe.toMap()),
              )
            : http.put(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(classe.toMap()),
              ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          _classNameController.clear();
          _studentCountController.clear();
          _editingClass = null;
          Navigator.pop(context); // Fermer le dialogue
          _loadClasses(); // Recharger la liste
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
        } else {
          print('Erreur lors de la requête: ${response.statusCode}');
        }
      } catch (e) {
        print('Error saving class: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'opération'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAddingOrEditing = false;
        });
      }
    }
  }

  Future<void> _deleteClass(int classId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/classes/$classId'),
      );
      if (response.statusCode == 200) {
        _loadClasses();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Classe supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de la classe'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddOrEditClassDialog({Classe? classe}) {
    _editingClass = classe;
    _classNameController.text = classe?.nomClass ?? '';
    _studentCountController.text = classe?.nbreEtud.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isAddingOrEditing ? null : _saveClass,
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _classes.isEmpty
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
                  SizedBox(height: 8),
                  Text(
                    "Ajoutez votre première classe",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Column(
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
                        _classes
                            .fold(0, (sum, c) => sum + c.nbreEtud)
                            .toString(),
                        Icons.people,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classe = _classes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
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
                          subtitle: Text(
                            '${classe.nbreEtud} étudiants',
                            style: GoogleFonts.poppins(),
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
                                onPressed: () =>
                                    _showDeleteConfirmation(classe),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditClassDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
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
