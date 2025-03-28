class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? category;
  final String? location;
  final String role;
  final String? image;
  final bool isDeleted;
  final int? points;
  List<num>? ratings;
  final num? gmSaved;

  UserModel({
    required this.isDeleted,
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.category,
    this.location,
    required this.role,
    this.image,
    this.points,
    this.ratings,
    this.gmSaved,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      isDeleted: data['isDeleted'],
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      category: data['category'],
      location: data['location'],
      role: data['role'],
      image: data['image'],
      points: data['points'],
      ratings: data['ratings'] != null ? List<num>.from(data['ratings']) : null,
      gmSaved: data['gmSaved'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDeleted': isDeleted,
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'category': category,
      'location': location,
      'role': role,
      'image': image,
      'points': points,
      'ratings': ratings,
      'gmSaved': gmSaved,
    };
  }

  //add copywith
  UserModel copyWith({
    bool? isDeleted,
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? category,
    String? location,
    String? role,
    String? image,
    int? points,
    num? gmSaved,
  }) {
    return UserModel(
      isDeleted: isDeleted ?? this.isDeleted,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      location: location ?? this.location,
      role: role ?? this.role,
      image: image ?? this.image,
      points: points ?? this.points,
      gmSaved: gmSaved ?? this.gmSaved,
    );
  }
}
