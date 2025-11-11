// formation_management.dart
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tp7_flutter/Formation.dart';
import 'package:tp7_flutter/User.dart';

class FormationManagement extends StatefulWidget {
  final User user;
  const FormationManagement({Key? key, required this.user}) : super(key: key);

  @override
  _FormationManagementState createState() => _FormationManagementState();
}

class _FormationManagementState extends State<FormationManagement> {
  List<Formation> _formations = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _formationNameController = TextEditingController();
  final _durationController = TextEditingController();

  final String baseUrl = "http://10.0.2.2:8095";
  bool _isAddingOrEditing = false;
  Formation? _editingFormation;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/formations'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _formations = data.map((item) => Formation.fromMap(item)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading formations: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFormation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isAddingOrEditing = true);
      try {
        final formation = Formation(
          nom: _formationNameController.text,
          duree: int.parse(_durationController.text),
          id: _editingFormation?.id,
        );

        final uri = _editingFormation == null
            ? Uri.parse('$baseUrl/formations')
            : Uri.parse('$baseUrl/formations/${_editingFormation!.id}');

        final response = await (_editingFormation == null
            ? http.post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(formation.toMap()),
              )
            : http.put(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(formation.toMap()),
              ));

        if (response.statusCode == 200 || response.statusCode == 201) {
          _formationNameController.clear();
          _durationController.clear();
          _editingFormation = null;
          Navigator.pop(context);
          _loadFormations();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingFormation == null
                    ? 'Formation ajoutée avec succès'
                    : 'Formation modifiée avec succès',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Erreur lors de la requête: ${response.statusCode}');
        }
      } catch (e) {
        print('Error saving formation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'opération'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isAddingOrEditing = false);
      }
    }
  }

  Future<void> _deleteFormation(int formationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/formations/$formationId'),
      );
      if (response.statusCode == 200) {
        _loadFormations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Formation supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting formation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de la formation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddOrEditFormationDialog({Formation? formation}) {
    _editingFormation = formation;
    _formationNameController.text = formation?.nom ?? '';
    _durationController.text = formation?.duree.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            formation == null
                ? "Ajouter une formation"
                : "Modifier la formation",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _formationNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom de la formation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer le nom de la formation'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Durée (mois)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer la durée';
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
              onPressed: _isAddingOrEditing ? null : _saveFormation,
              child: _isAddingOrEditing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(formation == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Formation formation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text(
            "Êtes-vous sûr de vouloir supprimer la formation ${formation.nom} ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFormation(formation.id!);
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
          : _formations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "Aucune formation disponible",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ajoutez votre première formation",
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
                  color: Colors.purple[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total Formations',
                        _formations.length.toString(),
                        Icons.menu_book,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Durée Moyenne',
                        '${_formations.isNotEmpty ? _formations.fold(0, (sum, f) => sum + f.duree) ~/ _formations.length : 0} mois',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _formations.length,
                    itemBuilder: (context, index) {
                      final formation = _formations[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple[100],
                            child: Icon(
                              Icons.menu_book,
                              color: Colors.purple[800],
                            ),
                          ),
                          title: Text(
                            formation.nom,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Durée: ${formation.duree} mois',
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _showAddOrEditFormationDialog(
                                  formation: formation,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _showDeleteConfirmation(formation),
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
        onPressed: () => _showAddOrEditFormationDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[800],
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
    _formationNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
