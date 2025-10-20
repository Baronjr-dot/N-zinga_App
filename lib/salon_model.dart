// lib/salon_model.dart

class Salon {
  final String name;
  final String address;
  final String openingHours;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<Service> services;
  final List<Review> reviews;

  Salon({
    required this.name,
    required this.address,
    required this.openingHours,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.services,
    required this.reviews,
  });
}

class Service {
  final String name;
  final String price;

  Service({required this.name, required this.price});
}

class Review {
  final String userName;
  final String comment;
  final int rating;

  Review({required this.userName, required this.comment, required this.rating});
}