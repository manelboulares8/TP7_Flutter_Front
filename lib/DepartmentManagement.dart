// department_management.dart
import 'package:flutter/material.dart';
import 'package:tp7_flutter/Department.dart';
import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/DepartmentService.dart';

class DepartmentManagement extends StatefulWidget {
  const DepartmentManagement({Key? key}) : super(key: key);

  @override
  _DepartmentManagementState createState() => _DepartmentManagementState();
}

class _DepartmentManagementState extends State<DepartmentManagement> {
  List<Department> departments = [];
  List<Classe> classes = [];
  Department? selectedDepartment;
  bool isLoading = false;
  bool showClasses = false;

  TextEditingController nomDeptController = TextEditingController();
  TextEditingController editNomDeptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    setState(() {
      isLoading = true;
    });
    try {
      departments = await DepartmentService.getDepartments();
      setState(() {});
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement des départements: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadClasses(int deptId) async {
    setState(() {
      isLoading = true;
    });
    try {
      classes = await DepartmentService.getClassesByDepartment(deptId);
      setState(() {
        showClasses = true;
      });
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement des classes: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addDepartment() async {
    if (nomDeptController.text.isEmpty) {
      _showErrorDialog('Veuillez saisir le nom du département');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Department newDepartment = Department(nomDept: nomDeptController.text);

      await DepartmentService.createDepartment(newDepartment);
      nomDeptController.clear();
      await loadDepartments();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Département ajouté avec succès')));
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'ajout: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateDepartment() async {
    if (selectedDepartment == null || editNomDeptController.text.isEmpty) {
      _showErrorDialog('Veuillez sélectionner un département et saisir un nom');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Department updatedDepartment = Department(
        codDept: selectedDepartment!.codDept,
        nomDept: editNomDeptController.text,
      );

      await DepartmentService.updateDepartment(updatedDepartment);
      editNomDeptController.clear();
      selectedDepartment = null;
      await loadDepartments();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Département modifié avec succès')),
      );
    } catch (e) {
      _showErrorDialog('Erreur lors de la modification: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteDepartment(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce département ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        isLoading = true;
      });

      try {
        await DepartmentService.deleteDepartment(id);
        await loadDepartments();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Département supprimé avec succès')),
        );
      } catch (e) {
        _showErrorDialog('Erreur lors de la suppression: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDepartmentDetails(Department department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du Département'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${department.codDept}'),
              Text('Nom: ${department.nomDept}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    selectedDepartment = department;
                    showClasses = true;
                  });
                  loadClasses(department.codDept!);
                },
                child: Text('Voir les classes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
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
        title: Text('Gestion des Départements'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Add Department Form
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Ajouter un Département',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: nomDeptController,
                            decoration: InputDecoration(
                              labelText: 'Nom du Département',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: addDepartment,
                            child: Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Edit Department Form
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Modifier un Département',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<Department>(
                            value: selectedDepartment,
                            decoration: InputDecoration(
                              labelText: 'Sélectionner un Département',
                              border: OutlineInputBorder(),
                            ),
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
                                  editNomDeptController.text = newValue.nomDept;
                                }
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: editNomDeptController,
                            decoration: InputDecoration(
                              labelText: 'Nouveau nom',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: updateDepartment,
                            child: Text('Modifier'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Departments List
                  Expanded(
                    child: showClasses
                        ? _buildClassesList()
                        : _buildDepartmentsList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDepartmentsList() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Liste des Départements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: departments.length,
              itemBuilder: (context, index) {
                Department department = departments[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.account_balance, color: Colors.blue),
                    title: Text(department.nomDept),
                    subtitle: Text('ID: ${department.codDept}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info, color: Colors.blue),
                          onPressed: () => _showDepartmentDetails(department),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              deleteDepartment(department.codDept!),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedDepartment = department;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      showClasses = false;
                      classes.clear();
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Classes du Département: ${selectedDepartment?.nomDept}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? Center(
                    child: Text(
                      'Aucune classe dans ce département',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      Classe classe = classes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.class_, color: Colors.green),
                          title: Text(classe.nomClass),
                          subtitle: Text(
                            'Nombre d\'étudiants: ${classe.nbreEtud}',
                          ),
                          trailing: Text('ID: ${classe.codClass}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
