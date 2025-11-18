import 'package:tp7_flutter/Department.dart';

class Classe {
  final int? codClass;
  final String nomClass;
  final int nbreEtud;
  final Department? department;

  Classe({
    this.codClass,
    required this.nomClass,
    required this.nbreEtud,
    this.department,
  });

  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      codClass: map['codClass'],
      nomClass: map['nomClass'],
      nbreEtud: map['nbreEtud'],
      department: map['department'] != null
          ? Department.fromMap(map['department'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'codClass': codClass,
      'nomClass': nomClass,
      'nbreEtud': nbreEtud,
      'department': department?.toMap(),
    };
  }
}
