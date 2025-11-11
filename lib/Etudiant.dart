import 'package:tp7_flutter/Classe.dart';
import 'package:tp7_flutter/Formation.dart';

class Etudiant {
  final int? id;
  final String nom;
  final String prenom;
  final DateTime dateNais;
  final Formation? formation;
  final Classe? classe;

  Etudiant({
    this.id,
    required this.nom,
    required this.prenom,
    required this.dateNais,
    this.formation,
    this.classe,
  });

  factory Etudiant.fromMap(Map<String, dynamic> map) {
    return Etudiant(
      id: map['id'] as int?,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      dateNais: DateTime.parse(
        map['dateNais'] ?? DateTime.now().toIso8601String(),
      ),
      formation: map['formation'] != null
          ? Formation.fromMap(map['formation'])
          : null,
      classe: map['classe'] != null ? Classe.fromMap(map['classe']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateNais': dateNais.toIso8601String(),
      'formation': formation?.toMap(),
      'classe': classe?.toMap(),
    };
  }
}
