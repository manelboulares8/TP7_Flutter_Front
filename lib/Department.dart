class Department {
  final int? codDept;
  final String nomDept;

  Department({this.codDept, required this.nomDept});

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(codDept: map['codDept'], nomDept: map['nomDept']);
  }

  Map<String, dynamic> toMap() {
    return {'codDept': codDept, 'nomDept': nomDept};
  }
}
