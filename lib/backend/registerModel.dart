class Registermodel {
  String userId;
  String name;
  String email;
  String birthdate;
  double weight;
  double height;
  List<String> categories;

  static const CollectionName = 'project';

  Registermodel({
    required this.userId,
    required this.name,
    required this.email,
    required this.birthdate,
    required this.weight,
    required this.height,
    required this.categories,
  });

  factory Registermodel.fromJson(Map<String, dynamic> json) {
    return Registermodel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      birthdate: json['birthdate'],
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'birthdate': birthdate,
      'weight': weight,
      'height': height,
      'categories': categories,
    };
  }
}
