// formation.dart
import 'dart:ffi';

class Formation {
  final int? id;
  final String nom;
  final int duree;

  Formation({this.id, required this.nom, required this.duree});

  factory Formation.fromMap(Map<String, dynamic> map) {
    return Formation(id: map['id'], nom: map['nom'], duree: map['duree']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'duree': duree};
  }
}
