// class_model.dart
import 'dart:ffi';

class Classe {
  final int? codClass;
  final String nomClass;
  final int nbreEtud;

  Classe({this.codClass, required this.nomClass, required this.nbreEtud});

  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      codClass: map['codClass'],
      nomClass: map['nomClass'],
      nbreEtud: map['nbreEtud'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'codClass': codClass, 'nomClass': nomClass, 'nbreEtud': nbreEtud};
  }
}
