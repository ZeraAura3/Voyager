// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String studentId;
  final String phone;
  final double rating;
  final int totalRides;
  final double moneySaved;
  final DateTime? createdAt;
  final String? profileImageUrl;
  final bool isDriver;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.phone,
    this.rating = 5.0,
    this.totalRides = 0,
    this.moneySaved = 0.0,
    this.createdAt,
    this.profileImageUrl,
    this.isDriver = false,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'phone': phone,
      'rating': rating,
      'totalRides': totalRides,
      'moneySaved': moneySaved,
      'createdAt': createdAt?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'isDriver': isDriver,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      studentId: map['studentId'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      moneySaved: (map['moneySaved'] ?? 0.0).toDouble(),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      profileImageUrl: map['profileImageUrl'],
      isDriver: map['isDriver'] ?? false,
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? studentId,
    String? phone,
    double? rating,
    int? totalRides,
    double? moneySaved,
    DateTime? createdAt,
    String? profileImageUrl,
    bool? isDriver,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      moneySaved: moneySaved ?? this.moneySaved,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isDriver: isDriver ?? this.isDriver,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, studentId: $studentId, rating: $rating)';
  }
}

// lib/models/ride_model.dart

class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final String fromLocation;
  final String toLocation;
  final DateTime date;
  final String time;
  final int availableSeats;
  final int totalSeats;
  final double pricePerPerson;
  final String? vehicleType;
  final String? vehicleNumber;
  final List<String> bookedUserIds;
  final DateTime? createdAt;
  final String status; // 'active', 'completed', 'cancelled'

  RideModel({
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.driverRating,
    required this.fromLocation,
    required this.toLocation,
    required this.date,
    required this.time,
    required this.availableSeats,
    required this.totalSeats,
    required this.pricePerPerson,
    this.vehicleType,
    this.vehicleNumber,
    this.bookedUserIds = const [],
    this.createdAt,
    this.status = 'active',
  });

  // Convert RideModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'driverName': driverName,
      'driverRating': driverRating,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'date': date.toIso8601String(),
      'time': time,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'pricePerPerson': pricePerPerson,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'bookedUserIds': bookedUserIds,
      'createdAt': createdAt?.toIso8601String(),
      'status': status,
    };
  }

  // Create RideModel from Firestore Map
  factory RideModel.fromMap(Map<String, dynamic> map, String rideId) {
    return RideModel(
      rideId: rideId,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      driverRating: (map['driverRating'] ?? 5.0).toDouble(),
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      availableSeats: map['availableSeats'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      pricePerPerson: (map['pricePerPerson'] ?? 0.0).toDouble(),
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      bookedUserIds: List<String>.from(map['bookedUserIds'] ?? []),
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      status: map['status'] ?? 'active',
    );
  }

  // Create a copy with updated fields
  RideModel copyWith({
    String? rideId,
    String? driverId,
    String? driverName,
    double? driverRating,
    String? fromLocation,
    String? toLocation,
    DateTime? date,
    String? time,
    int? availableSeats,
    int? totalSeats,
    double? pricePerPerson,
    String? vehicleType,
    String? vehicleNumber,
    List<String>? bookedUserIds,
    DateTime? createdAt,
    String? status,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      date: date ?? this.date,
      time: time ?? this.time,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      bookedUserIds: bookedUserIds ?? this.bookedUserIds,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'RideModel(rideId: $rideId, from: $fromLocation, to: $toLocation, date: $date, seats: $availableSeats)';
  }
}

// lib/models/booking_model.dart

class BookingModel {
  final String bookingId;
  final String rideId;
  final String riderId;
  final String riderName;
  final String driverId;
  final String driverName;
  final String fromLocation;
  final String toLocation;
  final DateTime rideDate;
  final String rideTime;
  final int seatsBooked;
  final double totalPrice;
  final DateTime? bookedAt;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? cancellationReason;

  BookingModel({
    required this.bookingId,
    required this.rideId,
    required this.riderId,
    required this.riderName,
    required this.driverId,
    required this.driverName,
    required this.fromLocation,
    required this.toLocation,
    required this.rideDate,
    required this.rideTime,
    required this.seatsBooked,
    required this.totalPrice,
    this.bookedAt,
    this.status = 'pending',
    this.cancellationReason,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'rideId': rideId,
      'riderId': riderId,
      'riderName': riderName,
      'driverId': driverId,
      'driverName': driverName,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'rideDate': rideDate.toIso8601String(),
      'rideTime': rideTime,
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'bookedAt': bookedAt?.toIso8601String(),
      'status': status,
      'cancellationReason': cancellationReason,
    };
  }

  // Create from Firestore Map
  factory BookingModel.fromMap(Map<String, dynamic> map, String bookingId) {
    return BookingModel(
      bookingId: bookingId,
      rideId: map['rideId'] ?? '',
      riderId: map['riderId'] ?? '',
      riderName: map['riderName'] ?? '',
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
      rideDate: DateTime.parse(map['rideDate']),
      rideTime: map['rideTime'] ?? '',
      seatsBooked: map['seatsBooked'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      bookedAt:
          map['bookedAt'] != null ? DateTime.parse(map['bookedAt']) : null,
      status: map['status'] ?? 'pending',
      cancellationReason: map['cancellationReason'],
    );
  }

  // Copy with updated fields
  BookingModel copyWith({
    String? bookingId,
    String? rideId,
    String? riderId,
    String? riderName,
    String? driverId,
    String? driverName,
    String? fromLocation,
    String? toLocation,
    DateTime? rideDate,
    String? rideTime,
    int? seatsBooked,
    double? totalPrice,
    DateTime? bookedAt,
    String? status,
    String? cancellationReason,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      rideId: rideId ?? this.rideId,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      rideDate: rideDate ?? this.rideDate,
      rideTime: rideTime ?? this.rideTime,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      totalPrice: totalPrice ?? this.totalPrice,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  String toString() {
    return 'BookingModel(bookingId: $bookingId, status: $status, seats: $seatsBooked)';
  }
}
