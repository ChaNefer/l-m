import 'package:les_social/models/user.dart';

class MoreAboutModel {
  String? orientation;
  String? sex;
  String? relationship;
  String? dreams;
  String? regrets;
  String? favWoman;
  String? children;
  String? pets;
  String? husband;
  String? religion;
  String? politics;
  String? diet;
  String? smoke;
  String? drink;
  String? sexPref;
  String? freeTime;
  String? livingTogether;
  String? parties;

  MoreAboutModel(
      {this.orientation,
      this.sex,
      this.relationship,
      this.dreams,
      this.regrets,
      this.favWoman,
      this.children,
      this.pets,
      this.husband,
      this.religion,
      this.politics,
      this.diet,
      this.smoke,
      this.drink,
      this.sexPref,
      this.freeTime,
      this.livingTogether,
      this.parties});

  MoreAboutModel.fromJson(Map<String, dynamic> json) {
    orientation = json['orientation'];
    sex = json['sex'];
    relationship = json['relationship'];
    dreams = json['dreams'];
    regrets = json['regrets'];
    favWoman = json['favWoman'];
    children = json['children'];
    pets = json['pets'];
    husband = json['husband'];
    religion = json['religion'];
    politics = json['politics'];
    diet = json['diet'];
    smoke = json['smoke'];
    drink = json['drink'];
    sexPref = json['sexPref'];
    freeTime = json['freeTime'];
    livingTogether = json['livingTogether'];
    parties = json['parties'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orientation': orientation,
      'sex': sex,
      'relationship': relationship,
      'dreams': dreams,
      'regrets': regrets,
      'favWoman': favWoman,
      'children': children,
      'pets': pets,
      'husband': husband,
      'religion': religion,
      'politics': politics,
      'diet': diet,
      'smoke': smoke,
      'drink': drink,
      'sexPref': sexPref,
      'freeTime': freeTime,
      'livingTogether': livingTogether,
      'parties': parties
    };
    return data;
  }

  factory MoreAboutModel.fromUserModel(UserModel user) {
    return MoreAboutModel(
        sex: user.sex,
        orientation: user.orientation,
        relationship: user.relationship,
        dreams: user.dreams,
        regrets: user.regrets,
        favWoman: user.favWoman,
        children: user.children,
        pets: user.pets,
        husband: user.husband,
        religion: user.religion,
        politics: user.politics,
        diet: user.diet,
        smoke: user.smoke,
        drink: user.drink,
        sexPref: user.sexPref,
        freeTime: user.freeTime,
        livingTogether: user.livingTogether,
        parties: user.parties);
  }
}
