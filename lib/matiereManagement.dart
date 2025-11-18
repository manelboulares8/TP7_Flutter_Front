import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter/Matiere.dart';
import 'package:tp7_flutter/MatiereService.dart';
import 'dart:convert';

class MatiereManagement extends StatefulWidget {
  const MatiereManagement({Key? key}) : super(key: key);

  @override
  _MatiereManagementState createState() => _MatiereManagementState();
}

class _MatiereManagementState extends State<MatiereManagement> {
  List<Matiere> _matieres = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _intMatController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isAddingOrEditing = false;
  Matiere? _editingMatiere;

  @override
  void initState() {
    super.initState();
    _loadMatieres();
  }

  Future<void> _loadMatieres() async {
    try {
      _matieres = await MatiereService.getMatieres();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading matieres: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMatiere() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingOrEditing = true;
      });

      try {
        final matiere = Matiere(
          codMat: _editingMatiere?.codMat,
          intMat: _intMatController.text,
          description: _descriptionController.text,
        );

        if (_editingMatiere == null) {
          await MatiereService.createMatiere(matiere);
        } else {
          await MatiereService.updateMatiere(matiere);
        }

        _resetForm();
        Navigator.pop(context);
        await _loadMatieres();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingMatiere == null
                  ? 'Matière ajoutée avec succès'
                  : 'Matière modifiée avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isAddingOrEditing = false;
        });
      }
    }
  }

  void _resetForm() {
    _intMatController.clear();
    _descriptionController.clear();
    _editingMatiere = null;
  }

  Future<void> _deleteMatiere(int matiereId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette matière ?'),
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
        await MatiereService.deleteMatiere(matiereId);
        await _loadMatieres();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Matière supprimée avec succès'),
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

  void _showAddOrEditMatiereDialog({Matiere? matiere}) {
    _editingMatiere = matiere;
    _intMatController.text = matiere?.intMat ?? '';
    _descriptionController.text = matiere?.description ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            matiere == null ? "Ajouter une matière" : "Modifier la matière",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _intMatController,
                    decoration: InputDecoration(
                      labelText: 'Intitulé de la matière',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer l\'intitulé de la matière'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer une description'
                        : null,
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
              onPressed: _isAddingOrEditing ? null : _saveMatiere,
              child: _isAddingOrEditing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(matiere == null ? 'Ajouter' : 'Modifier'),
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
        title: Text('Gestion des Matières'),
        backgroundColor: Colors.purple[800],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _matieres.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "Aucune matière disponible",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ajoutez votre première matière",
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
                        'Total Matières',
                        _matieres.length.toString(),
                        Icons.menu_book,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _matieres.length,
                    itemBuilder: (context, index) {
                      final matiere = _matieres[index];
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
                            matiere.intMat,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            matiere.description,
                            style: GoogleFonts.poppins(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _showAddOrEditMatiereDialog(
                                  matiere: matiere,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteMatiere(matiere.codMat!),
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
        onPressed: () => _showAddOrEditMatiereDialog(),
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
    _intMatController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
