class Doctor {
  final String id;
  final String firstName;
  final String LastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String specialty;
  Doctor({
    required this.id,
    required this.firstName,
    required this.LastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.specialty,
  });

  // Convert JSON to Doctor object //
  Doctor.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      firstName = json['firstName'],
      LastName = json['LastName'],
      email = json['email'],
      phoneNumber = json['phoneNumber'],
      address = json['address'],
      specialty = json['specialty'];

  // Convert Doctor object to JSON //
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'LastName': LastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
    'specialty': specialty,
  };
}
