class Person {
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;
  final int userId;

  Person({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.userId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
    'user_id': userId,
  };
}
