class UserModel {
  String? username;
  String? email;
  String? photoUrl;
  String? country;
  String? city;
  String? orientation;
  String? sex;
  String? relationship;
  String? age;
  String? bio;
  String? id;
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
  bool? smokeCheckbox;
  bool? drinkCheckbox;
  bool? childrenCheckbox;
  bool? petsCheckbox;
  DateTime? signedUpAt;
  DateTime? lastSeen;
  bool? isOnline;
  double? longitude;
  double? latitude;
  double? profileCompletion;

  UserModel({
    this.username,
    this.email,
    this.id,
    this.photoUrl,
    this.signedUpAt,
    this.isOnline,
    this.lastSeen,
    this.bio,
    this.country,
    this.city,
    this.orientation,
    this.sex,
    this.relationship,
    this.age,
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
    this.parties,
    this.smokeCheckbox,
    this.drinkCheckbox,
    this.childrenCheckbox,
    this.petsCheckbox,
    this.longitude,
    this.latitude,
    this.profileCompletion,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    country = json['country'];
    city = json['city'];
    orientation = json['orientation'];
    sex = json['sex'];
    relationship = json['relationship'];
    age = json['age'];
    photoUrl = json['photoUrl'];
    signedUpAt = json['signedUpAt'] != null ? DateTime.tryParse(json['signedUpAt']) : null;
    isOnline = json['isOnline'] == 1 ? true : false;
    lastSeen = json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen']) : null;
    bio = json['bio'];
    id = json['id']; // Konwersja na int
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
    smokeCheckbox = json['smokeCheckbox'] == 1 ? true : false;
    drinkCheckbox = json['drinkCheckbox'] == 1 ? true : false;
    childrenCheckbox = json['childrenCheckbox'] == 1 ? true : false;
    petsCheckbox = json['petsCheckbox'] == 1 ? true : false;
    latitude = json['latitude'] != null ? (json['latitude'] as num).toDouble() : null;
    longitude = json['longitude'] != null ? (json['longitude'] as num).toDouble() : null;
    profileCompletion = json['profileCompletion'] != null ? (json['profileCompletion'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['email'] = email;
    data['photoUrl'] = photoUrl;
    data['country'] = country;
    data['city'] = city;
    data['orientation'] = orientation;
    data['sex'] = sex;
    data['relationship'] = relationship;
    data['age'] = age;
    data['bio'] = bio;
    data['id'] = id;
    data['dreams'] = dreams;
    data['regrets'] = regrets;
    data['favWoman'] = favWoman;
    data['children'] = children;
    data['pets'] = pets;
    data['husband'] = husband;
    data['religion'] = religion;
    data['politics'] = politics;
    data['diet'] = diet;
    data['smoke'] = smoke;
    data['drink'] = drink;
    data['sexPref'] = sexPref;
    data['freeTime'] = freeTime;
    data['livingTogether'] = livingTogether;
    data['parties'] = parties;
    data['smokeCheckbox'] = smokeCheckbox == true ? 1 : 0;
    data['drinkCheckbox'] = drinkCheckbox == true ? 1 : 0;
    data['childrenCheckbox'] = childrenCheckbox == true ? 1 : 0;
    data['petsCheckbox'] = petsCheckbox == true ? 1 : 0;
    data['signedUpAt'] = signedUpAt?.toIso8601String();
    data['lastSeen'] = lastSeen?.toIso8601String();
    data['isOnline'] = isOnline == true ? 1 : 0;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['profileCompletion'] = profileCompletion;
    return data;
  }
}
