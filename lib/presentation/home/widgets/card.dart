import 'package:flutter/material.dart';
import 'package:mytravaly/domain/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // --- Data Retrieval and Calculations (using real data) ---
    final overallRating = property.googleReview?.overallRating ?? 0.0;

    // 1. Get real review count from GoogleReview model
    final reviewCountText =
        overallRating > 0
            ? '${property.googleReview?.totalUserRating ?? 0} Reviews'
            : '';

    final starRating = property.propertyStar.clamp(1, 5);

    // CRITICAL FIX: Use null-aware access to safely retrieve price details
    final double safeMarkedAmount = property.markedPrice?.amount ?? 0.0;
    final double safeMinAmount = property.propertyMinPrice?.amount ?? 0.0;
    final String safeMarkedDisplay =
        property.markedPrice?.displayAmount ?? 'N/A';
    final String safeMinDisplay =
        property.propertyMinPrice?.displayAmount ?? 'N/A';

    // 2. Get real location text from PropertyAddress model
    final locationText =
        '${property.propertyAddress?.city ?? 'City'}, ${property.propertyAddress?.country ?? 'Country'}';

    // 3. Real Discount Calculation (based on markedPrice and propertyMinPrice)
    int discountPercentage = 0;

    if (safeMarkedAmount > 0 && safeMinAmount < safeMarkedAmount) {
      discountPercentage =
          ((safeMarkedAmount - safeMinAmount) / safeMarkedAmount * 100).round();
    }

    // 4. Offer price is the displayAmount from propertyMinPrice
    final offerPriceDisplay = safeMinDisplay;

    return Card(
      // 1. Style: Transparent background, no borders/elevation
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: width * 0.04),
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: IntrinsicHeight(
          // Use Row with Flexible/Expanded for 2:5 ratio layout
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    // User's requested aspect ratio (taller/narrower)
                    aspectRatio: 0.5,
                    child: Image.network(
                      property.propertyImage,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 5:5 Ratio - Content Column
              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Property Name
                    Text(
                      property.propertyName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 2. Stars (Rounded Rating)
                    Row(
                      children: List.generate(
                        starRating,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 3. Actual Rating and Reviews Row
                    if (overallRating > 0)
                      Row(
                        children: [
                          // Actual Rating in rounded container
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              overallRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Number of reviews (using real data)
                          Text(
                            reviewCountText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 6),

                    // 4. Location with Pin Icon (using real data)
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: Colors.grey.shade900,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationText, // Now using real data
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          property.roomName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade900,
                          ),
                        ),

                        const SizedBox(height: 6),

                        if (discountPercentage > 0 && discountPercentage != 100)
                          Text(
                            '$discountPercentage% off', // Now using real calculation
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade400,
                            ),
                          ),

                        const SizedBox(height: 6),

                        // 7. Marked Price (Slashed) and Offer Price (Conditional Slashed Price)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // Marked Price (Slashed) - ONLY show if a discount exists
                            if (discountPercentage > 0 &&
                                discountPercentage != 100)
                              Text(
                                safeMarkedDisplay, // Now using safe access
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),

                            // Separator - ONLY show if a discount exists
                            if (discountPercentage > 0)
                              const SizedBox(width: 8),

                            // Offer Price (always show the final price)
                            Text(
                              discountPercentage != 100
                                  ? offerPriceDisplay
                                  : safeMarkedDisplay, // Now using real propertyMinPrice data
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
