class UserCard {
  final String id;
  final String name;
  final int age;
  final String? description;
  final List<String> photos;

  UserCard({
    required this.id,
    required this.name,
    required this.age,
    this.description,
    required this.photos,
  });

  factory UserCard.fromMap(Map<String, dynamic> map) {
    final photos = (map['user_photos'] as List?) ?? [];

    return UserCard(
      id: map['id_user'],
      name: map['name'],
      age: map['age'],
      description: map['description'],
      photos: photos.isNotEmpty
          ? [photos.first['url']]
          : [],
    );
  }
}
