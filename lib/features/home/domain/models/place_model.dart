class PlaceModel {
  final String id;
  final String name;
  final String category;
  final String mood;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String distance;
  final String priceLevel;
  final String aiVibeSummary;
  final List<String> tags;
  final String crowdLevel;
  final String openHours;
  final bool isTrending;
  final double latitude;
  final double longitude;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.mood,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.priceLevel,
    required this.aiVibeSummary,
    required this.tags,
    required this.crowdLevel,
    required this.openHours,
    this.isTrending = false,
    this.latitude = 6.4281,
    this.longitude = 3.4219,
  });
}

class EventModel {
  final String id;
  final String title;
  final String placeName;
  final String time;
  final String distance;
  final int attendeesCount;
  final String imageUrl;
  final String badgeText;
  final String tag;
  final String venueAddress;
  final String description;
  final String ticketPrice;
  final String source;
  final double latitude;
  final double longitude;
  final String timeCategory;

  const EventModel({
    required this.id,
    required this.title,
    required this.placeName,
    required this.time,
    required this.distance,
    required this.attendeesCount,
    required this.imageUrl,
    required this.badgeText,
    required this.tag,
    this.venueAddress = 'Victoria Island, Lagos',
    this.description = '',
    this.ticketPrice = 'Free RSVP',
    this.source = 'Google Events',
    this.latitude = 6.4281,
    this.longitude = 3.4219,
    this.timeCategory = 'Tonight',
  });
}
