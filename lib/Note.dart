import 'package:tp7_flutter/Etudiant.dart';
import 'package:tp7_flutter/Matiere.dart';

class Note {
  final int? id;
  final int etudiantId;
  final int matiereId;
  final double valeurNote;
  final Etudiant? etudiant;
  final Matiere? matiere;

  Note({
    this.id,
    required this.etudiantId,
    required this.matiereId,
    required this.valeurNote,
    this.etudiant,
    this.matiere,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      etudiantId: map['etudiant'] != null
          ? (map['etudiant']['id'] ?? map['etudiantId'])
          : map['etudiantId'],
      matiereId: map['matiere'] != null
          ? (map['matiere']['codMat'] ?? map['matiereId'])
          : map['matiereId'],
      valeurNote: (map['valeurNote'] ?? 0.0).toDouble(),
      etudiant: map['etudiant'] != null
          ? Etudiant.fromMap(map['etudiant'])
          : null,
      matiere: map['matiere'] != null ? Matiere.fromMap(map['matiere']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'etudiant': {'id': etudiantId},
      'matiere': {'codMat': matiereId},
      'valeurNote': valeurNote,
    };
  }

  @override
  String toString() {
    return 'Note{id: $id, etudiantId: $etudiantId, matiereId: $matiereId, valeurNote: $valeurNote}';
  }
}
