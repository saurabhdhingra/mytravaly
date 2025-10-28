class PriceDetails {
  final String displayAmount;
  final double amount;

  PriceDetails({required this.displayAmount, required this.amount});

  factory PriceDetails.fromJson(Map<String, dynamic> json) {
    return PriceDetails(
      displayAmount: json['displayAmount'] ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GoogleReview {
  final double overallRating;

  GoogleReview({required this.overallRating});

  // NOTE: This factory assumes the JSON passed here contains {'data': {'overallRating': value}}
  factory GoogleReview.fromJson(Map<String, dynamic> json) {
    // Safely access nested structure with null checks
    final data = json['data'] as Map<String, dynamic>?;
    final rating = (data?['overallRating'] as num?)?.toDouble() ?? 0.0;
    return GoogleReview(
      overallRating: rating,
    );
  }
}

class Property {
  final String propertyName;
  final int propertyStar;
  final String propertyImage;
  final PriceDetails markedPrice;
  final GoogleReview? googleReview;

  Property({
    required this.propertyName,
    required this.propertyStar,
    required this.propertyImage,
    required this.markedPrice,
    this.googleReview,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Safely handling potential nulls for nested objects
    final googleReviewJson = json['googleReview'] as Map<String, dynamic>?;
    
    return Property(
      propertyName: json['propertyName'] ?? 'Unknown Property',
      propertyStar: json['propertyStar'] ?? 0,
      propertyImage: json['propertyImage'] ?? 'https://placehold.co/600x400/CCCCCC/333333?text=No+Image',
      markedPrice: PriceDetails.fromJson(json['markedPrice'] ?? {}),
      googleReview: (googleReviewJson != null && googleReviewJson['reviewPresent'] == true) 
          ? GoogleReview.fromJson(googleReviewJson) 
          : null,
    );
  }
}