
import 'package:flutter/material.dart';
import 'package:mytravaly/domain/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property.propertyImage,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.propertyName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        property.propertyStar, 
                        (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text(
                    //   property.staticPrice.displayAmount,
                    //   style: const TextStyle(
                    //     fontSize: 22,
                    //     fontWeight: FontWeight.w900,
                    //     color: Colors.indigo,
                    //   ),
                    // ),
                    const SizedBox(width: 8),
                    Text(
                      property.markedPrice.displayAmount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Review Section
                if (property.googleReview != null && property.googleReview!.overallRating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star_half, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${property.googleReview!.overallRating} (${(property.googleReview!.overallRating * 10).toInt()} Reviews)',
                        style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Action Button (Placeholder for Page 3)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to Page 3 (Property Details)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Go to Property Details (Page 3 TBD)'))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Deal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}