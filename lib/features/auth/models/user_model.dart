class UserModel {
  final String id;
  final String? customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;

  const UserModel({
    required this.id,
    this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerId: json['customerId']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': role,
        'isVerified': isVerified,
      };

  UserModel copyWith({
    String? id,
    String? customerId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
