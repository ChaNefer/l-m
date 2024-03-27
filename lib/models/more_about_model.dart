import 'package:les_social/models/user.dart';

class MoreAboutModel {
  String? orientation;
  String? sex;
  String? relationship;
  String? age;

  MoreAboutModel({
    this.orientation,
    this.sex,
    this.relationship,
    this.age,
  });


  MoreAboutModel.fromJson(Map<String, dynamic> json) {
    orientation = json['orientation'];
    sex = json['sex'];
    relationship = json['relationship'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orientation': orientation,
      'sex': sex,
      'relationship': relationship,
      'age': age,
    };
    return data;
  }

  factory MoreAboutModel.fromUserModel(UserModel user) {
    return MoreAboutModel(
      sex: user.sex,
      orientation: user.orientation,
      age: user.age,
      relationship: user.relationship,
    );
  }
}
