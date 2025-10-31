import 'package:intl/intl.dart'; 

class Address {
  final String? city;
  final String? state;
  final String? country;

  Address.fromJson(Map<String, dynamic> json)
      : city = json['city'],
        state = json['state'],
        country = json['country'];
}

class SearchArray {
  final String type;
  final List<String> query;

  SearchArray.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? 'unknown',
        query = List<String>.from(json['query'] ?? []);
}

class SearchResultItem {
  final String valueToDisplay;
  final String? propertyName;
  final Address address;
  final SearchArray searchArray;

  SearchResultItem.fromJson(Map<String, dynamic> json)
      : valueToDisplay = json['valueToDisplay'] ?? '',
        propertyName = json['propertyName'],
        address = Address.fromJson(json['address'] ?? {}),
        searchArray = SearchArray.fromJson(json['searchArray'] ?? {});

  String get searchType => searchArray.type;
  List<String> get searchQuery => searchArray.query;
}


class SearchQueryData {
  String searchType;
  List<String> searchQuery;
  DateTime checkIn;
  DateTime checkOut;
  int rooms;
  int adults;
  int children;
  int limit;
  int rid; 
  List<String> accommodation;
  List<String> arrayOfExcludedSearchType;
  String highPrice;
  String lowPrice;
  List<dynamic> preloaderList;

  SearchQueryData({
    required this.searchType,
    required this.searchQuery,
    required this.checkIn,
    required this.checkOut,
    this.rooms = 1,
    this.adults = 2,
    this.children = 0,
    this.limit = 5,
    this.rid = 0,
    this.accommodation = const ["all"],
    this.arrayOfExcludedSearchType = const ["street"],
    this.highPrice = "3000000",
    this.lowPrice = "0",
    this.preloaderList = const [],
  });

  Map<String, dynamic> toJson() => {
    "searchType": searchType,
    "searchQuery": searchQuery,
    "checkIn": DateFormat('yyyy-MM-dd').format(checkIn),
    "checkOut": DateFormat('yyyy-MM-dd').format(checkOut),
    "rooms": rooms,
    "adults": adults,
    "children": children,
    "limit": limit,
    "preloaderList": preloaderList,
    "currency": "INR",
    "rid": rid,
    "accommodation": accommodation,
    "arrayOfExcludedSearchType": arrayOfExcludedSearchType,
    "highPrice": highPrice,
    "lowPrice": lowPrice,
  };

  static SearchQueryData initial() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return SearchQueryData(
      searchType: 'byCity',
      searchQuery: ['Jamshedpur', 'Jharkhand', 'India'],
      checkIn: now,
      checkOut: tomorrow,
    );
  }
}
