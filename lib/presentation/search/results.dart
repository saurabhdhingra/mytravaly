import 'package:flutter/material.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/property.dart';
import 'package:mytravaly/domain/property.dart';
import 'package:mytravaly/domain/search.dart';
import 'package:mytravaly/presentation/home/widgets/card.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  final SearchQueryData initialQuery;

  const SearchResultsPage({super.key, required this.initialQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final PropertyService _propertyService = PropertyService();
  final ScrollController _scrollController = ScrollController();
  final List<Property> _properties = [];
  late SearchQueryData _currentQuery;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
    _scrollController.addListener(_onScroll);
    _fetchResults(isInitial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoading) {
      // User reached the end, load next page (if available)
      _fetchResults();
    }
  }

  Future<void> _fetchResults({bool isInitial = false}) async {
    if (_isLoading) return;

    // Reset query for initial load
    if (isInitial) {
      _currentQuery.rid = 0;
      _properties.clear();
      _hasMore = true;
    }

    if (!_hasMore) {
      // No more data to load
      return;
    }

    setState(() {
      _isLoading = true;
      if (isInitial) _errorMessage = null;
    });

    final visitorToken =
        Provider.of<AuthNotifier>(context, listen: false).visitorToken;

    if (visitorToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token is missing.';
      });
      return;
    }

    try {
      final newProperties = await _propertyService.getSearchResultListOfHotels(
        _currentQuery,
        visitorToken,
      );

      if (mounted) {
        setState(() {
          _properties.addAll(newProperties);
          _isLoading = false;
          _currentQuery.rid += 1; // Increment RID for next page

          // Basic pagination check: if we got less than the limit, assume no more pages
          if (newProperties.length < _currentQuery.limit) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Search error: ${e.toString()}';
          _isLoading = false;
          _hasMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Results',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade900,
      body:
          _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              )
              : _properties.isEmpty && !_isLoading
              ? const Center(
                child: Text(
                  'No hotels found for your search criteria.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                itemCount:
                    _properties.length + (_hasMore || _isLoading ? 1 : 0),
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 1,
                    indent: width * 0.05,
                    endIndent: width * 0.05,
                  );
                },
                itemBuilder: (context, index) {
                  if (index == _properties.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.pink,
                                )
                                : _hasMore
                                ? null
                                : const Text(
                                  'End of Results',
                                  style: TextStyle(color: Colors.grey),
                                ),
                      ),
                    );
                  }
                  return PropertyCard(property: _properties[index]);
                },
              ),
    );
  }
}
