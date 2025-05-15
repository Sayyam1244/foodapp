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
  final num? points;
  List<num>? ratings;
  final num? gmSaved;
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      isDeleted: data['isDeleted'] ?? false,
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
      latitude: data['latitude'],
      longitude: data['longitude'],
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
      'latitude': latitude,
      'longitude': longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
