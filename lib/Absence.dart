import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Matiere.dart';

class Absence {
  final int? id;
  final int? etudiantId; // Rend nullable
  final int? matiereId; // Rend nullable
  final DateTime dateA;
  final int nha;
  final Matiere? matiere;
  final Etudiant? etudiant;

  Absence({
    this.id,
    this.etudiantId,
    this.matiereId,
    required this.dateA,
    required this.nha,
    this.matiere,
    this.etudiant,
  });

  factory Absence.fromMap(Map<String, dynamic> map) {
    print('🔄 Mapping Absence: $map');

    return Absence(
      id: map['id'],
      etudiantId: map['etudiant'] != null
          ? (map['etudiant']['id'] ?? map['etudiantId'])
          : map['etudiantId'],
      matiereId: map['matiere'] != null
          ? (map['matiere']['codMat'] ?? map['matiereId'])
          : map['matiereId'],
      dateA: DateTime.parse(map['dateA'] ?? DateTime.now().toIso8601String()),
      nha: map['nha'] ?? 0,
      matiere: map['matiere'] != null ? Matiere.fromMap(map['matiere']) : null,
      etudiant: map['etudiant'] != null
          ? Etudiant.fromMap(map['etudiant'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'etudiant': {'id': etudiantId},
      'matiere': {'codMat': matiereId},
      'dateA': dateA.toIso8601String().split('T')[0],
      'nha': nha,
    };
  }

  @override
  String toString() {
    return 'Absence{id: $id, etudiantId: $etudiantId, matiereId: $matiereId, dateA: $dateA, nha: $nha}';
  }
}
