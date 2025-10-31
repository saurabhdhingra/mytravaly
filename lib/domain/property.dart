class PriceDetails {
  final String displayAmount;
  final double amount;
  final String? currencySymbol; 

  PriceDetails({
    required this.displayAmount,
    required this.amount,
    this.currencySymbol,
  });

  factory PriceDetails.fromJson(Map<String, dynamic> json) {
    return PriceDetails(
      displayAmount: json['displayAmount'] ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currencySymbol: json['currencySymbol'],
    );
  }
}

class GoogleReview {
  final double overallRating;
  final int totalUserRating; 

  GoogleReview({required this.overallRating, required this.totalUserRating});

  factory GoogleReview.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return GoogleReview(
      overallRating: (data?['overallRating'] as num?)?.toDouble() ?? 0.0,
      totalUserRating: (data?['totalUserRating'] as int?) ?? 0,
    );
  }
}

class PropertyAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipcode;

  PropertyAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? '',
    );
  }
}

class PropertyPolicies {
  final bool freeWifi;
  final bool freeCancellation;
  final bool petsAllowed;

  PropertyPolicies({
    this.freeWifi = false,
    this.freeCancellation = false,
    this.petsAllowed = false,
  });

  factory PropertyPolicies.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return PropertyPolicies(
      freeWifi: data?['freeWifi'] ?? false,
      freeCancellation: data?['freeCancellation'] ?? false,
      petsAllowed: data?['petsAllowed'] ?? false,
    );
  }
}

class Property {
  final String propertyName;
  final int propertyStar;
  final String propertyImage;
  final PriceDetails markedPrice;
  final GoogleReview? googleReview;

  final String roomName;
  final PriceDetails propertyMinPrice;
  final PropertyAddress? propertyAddress;
  final PropertyPolicies? policies;
  Property({
    required this.propertyName,
    required this.propertyStar,
    required this.propertyImage,
    required this.markedPrice,
    required this.roomName,
    required this.propertyMinPrice,
    this.propertyAddress,
    this.policies,
    this.googleReview,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final googleReviewJson = json['googleReview'] as Map<String, dynamic>?;
    final policiesJson =
        json['propertyPoliciesAndAmmenities'] as Map<String, dynamic>?;

    final dynamic imageField = json['propertyImage'];
    String imageUrl;

    if (imageField is Map<String, dynamic> && imageField['fullUrl'] is String) {
      imageUrl = imageField['fullUrl'] as String;
    } else if (imageField is String) {
      imageUrl = imageField;
    } else {
      imageUrl = 'https://placehold.co/600x400/CCCCCC/333333?text=No+Image';
    }

    final addressJson = json['propertyAddress'] as Map<String, dynamic>?;

    return Property(
      propertyName: json['propertyName'] ?? 'Unknown Property',
      propertyStar: json['propertyStar'] ?? 0,
      propertyImage: imageUrl,
      markedPrice: PriceDetails.fromJson(json['markedPrice'] ?? {}),

      roomName: json['roomName'] ?? '',
      propertyMinPrice: PriceDetails.fromJson(json['propertyMinPrice'] ?? {}),

      propertyAddress:
          addressJson != null ? PropertyAddress.fromJson(addressJson) : null,
      policies:
          (policiesJson != null && policiesJson['present'] == true)
              ? PropertyPolicies.fromJson(policiesJson)
              : null,

      googleReview:
          (googleReviewJson != null &&
                  googleReviewJson['reviewPresent'] == true)
              ? GoogleReview.fromJson(googleReviewJson)
              : null,
    );
  }
}
