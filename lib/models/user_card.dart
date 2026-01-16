class UserCard {
  final String id;
  final String name;
  final int age;
  final String? description;
  final String? degreeName;
  final List<String> photos;
  final String? instagramUser;
  final String? gender;
  final String? lookingFor;
  final List<String> habits;

  UserCard({
    required this.id,
    required this.name,
    required this.age,
    this.description,
    this.degreeName,
    required this.photos,
    this.instagramUser,
    this.gender,
    this.lookingFor,
    this.habits = const [],
  });

  factory UserCard.fromMap(Map<String, dynamic> map) {
    final photosList = (map['user_photos'] as List?)
        ?.map((photo) => photo['url'] as String)
        .toList() ??
        <String>[];

    final genderName = map['genders']?['name'] as String?;
    final rawDegreeName = map['degrees']?['name'] as String?;
    final customDegree = map['custom_degree'] as String?;
    final lookingForName = map['looking_for']?['name'] as String?;

    final String? degreeName =
    (rawDegreeName == 'Otra' && customDegree != null && customDegree.isNotEmpty)
        ? customDegree
        : rawDegreeName;

    final habitsList = (map['user_has_life_habits'] as List?)
        ?.map((habit) => habit['life_habits']?['name'] as String?)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList() ??
        <String>[];

    return UserCard(
      id: map['id_user'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      description: map['description'] as String?,
      instagramUser: map['instagram_user'] as String?,
      degreeName: degreeName,
      photos: photosList,
      gender: genderName,
      lookingFor: lookingForName,
      habits: habitsList,
    );
  }
}