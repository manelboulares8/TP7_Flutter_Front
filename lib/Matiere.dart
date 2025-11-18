class Matiere {
  final int? codMat;
  final String intMat;
  final String description;

  Matiere({this.codMat, required this.intMat, required this.description});

  factory Matiere.fromMap(Map<String, dynamic> map) {
    return Matiere(
      codMat: map['codMat'],
      intMat: map['intMat'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'codMat': codMat, 'intMat': intMat, 'description': description};
  }
}
