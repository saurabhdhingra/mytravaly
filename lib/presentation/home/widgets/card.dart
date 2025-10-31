import 'package:flutter/material.dart';
import 'package:mytravaly/domain/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    final overallRating = property.googleReview?.overallRating ?? 0.0;

    final reviewCountText =
        overallRating > 0
            ? '${property.googleReview?.totalUserRating ?? 0} Reviews'
            : '';

    final starRating = property.propertyStar.clamp(1, 5);

    final double safeMarkedAmount = property.markedPrice.amount;
    final double safeMinAmount = property.propertyMinPrice.amount ;
    final String safeMarkedDisplay =
        property.markedPrice.displayAmount ;
    final String safeMinDisplay =
        property.propertyMinPrice.displayAmount ;

    final locationText =
        '${property.propertyAddress?.city ?? 'City'}, ${property.propertyAddress?.country ?? 'Country'}';

    int discountPercentage = 0;

    if (safeMarkedAmount > 0 && safeMinAmount < safeMarkedAmount) {
      discountPercentage =
          ((safeMarkedAmount - safeMinAmount) / safeMarkedAmount * 100).round();
    }


    final offerPriceDisplay = safeMinDisplay;

    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: width * 0.04),
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
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

              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

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


                    if (overallRating > 0)
                      Row(
                        children: [

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
                            locationText, 
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
                            '$discountPercentage% off',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade400,
                            ),
                          ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
            
                            if (discountPercentage > 0 &&
                                discountPercentage != 100)
                              Text(
                                safeMarkedDisplay, 
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),


                            if (discountPercentage > 0)
                              const SizedBox(width: 8),

             
                            Text(
                              discountPercentage != 100
                                  ? offerPriceDisplay
                                  : safeMarkedDisplay,
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
