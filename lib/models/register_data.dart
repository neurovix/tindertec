import 'dart:io';

class RegisterData {
  String? name;
  String? email;
  String? password;
  int? age;
  String? description;
  String? instagramUser;
  String? gender;
  String? degree;
  String? lookingFor;
  String? interest;
  List<String>? habits;
  List<File>? photos;

  RegisterData({
    this.name,
    this.age,
    this.description,
    this.instagramUser,
    this.gender,
    this.degree,
    this.lookingFor,
    this.interest,
    this.habits,
    this.photos
  });
}
