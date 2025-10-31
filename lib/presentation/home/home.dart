import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/property.dart';
import 'package:mytravaly/domain/property.dart';
import 'package:mytravaly/domain/search.dart';
import 'package:mytravaly/presentation/home/widgets/card.dart';
import 'package:mytravaly/presentation/search/results.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final FocusNode _inputFocusNode = FocusNode();
  bool _isFocused = false;

  final SearchQueryData _queryData = SearchQueryData.initial();
  List<SearchResultItem> _autocompleteResults = [];
  bool _isSearching = false;

  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;

  // DEBOUNCING
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAutocomplete(_searchController.text);
    });
  }

  Future<void> _fetchAutocomplete(String input) async {
    if (input.isEmpty) {
      setState(() {
        _autocompleteResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    final visitorToken =
        Provider.of<AuthNotifier>(context, listen: false).visitorToken;

    if (visitorToken == null) return;

    final results = await _propertyService.searchAutoComplete(
      input,
      visitorToken,
    );

    if (mounted) {
      setState(() {
        _autocompleteResults = results;
      });
    }
  }

  void _selectSearchResult(SearchResultItem item) {
    setState(() {
      _queryData.searchType = item.searchType;
      _queryData.searchQuery = item.searchQuery;

      _searchController.text = item.valueToDisplay;

      _autocompleteResults = [];
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final initialDate = isCheckIn ? _queryData.checkIn : _queryData.checkOut;
    final firstDate = DateTime.now();
    final lastDate = DateTime(2027);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _queryData.checkIn = picked;
          if (_queryData.checkOut.isBefore(picked)) {
            _queryData.checkOut = picked.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_queryData.checkIn)) {
            _queryData.checkOut = picked;
          }
        }
      });
    }
  }

  void _navigateToResults() {
    if (_queryData.searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a destination from the suggestions.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(initialQuery: _queryData),
      ),
    );
  }

  Future<void> _fetchProperties() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final visitorToken = authNotifier.visitorToken;

    if (visitorToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Authentication token is missing. Please sign in again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final properties = await _propertyService.fetchProperties(visitorToken);
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not fetch hotels: ${e.toString().split(':')[1].trim()}';
        _isLoading = false;
      });
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _inputFocusNode.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _inputFocusNode.addListener(_handleFocusChange);

    Future.microtask(() => _fetchProperties());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _inputFocusNode.removeListener(_handleFocusChange);
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello User',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              'Find an epic stay',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        centerTitle: false,
        actions: [
          SizedBox(
            width: width * 0.14,
            child: Padding(
              padding: EdgeInsets.only(right: width * 0.04),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authNotifier.signOut();

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully!')),
                    );
                  },
                  label: const Icon(Icons.logout, size: 24),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
              : _errorMessage != null
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
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Container(
                      width: width * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Stack(
                        children: [
                          _buildSearchForm(height, width),
                          if (_autocompleteResults.isNotEmpty && _isFocused)
                            _buildAutoCompleteSuggestions(height, width),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Text(
                      "Recommended",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _properties.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          indent: width * 0.05,
                          endIndent: width * 0.05,
                        );
                      },
                      itemBuilder: (context, index) {
                        return PropertyCard(property: _properties[index]);
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchForm(double height, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.004,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  focusNode: _inputFocusNode,
                  controller: _searchController,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search near by',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),

              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),

        Divider(height: 1, indent: 0, endIndent: 0),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.014,
          ),
          child: Row(
            children: [
              _buildDateButton(context, _queryData.checkIn, true),
              Text(
                "  -  ",
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              _buildDateButton(context, _queryData.checkOut, false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, indent: 0, endIndent: 0),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.014,
          ),
          child: GestureDetector(
            onTap: () => _showGuestRoomBottomSheet(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_queryData.rooms == 1 ? "1 room" : "${_queryData.rooms} rooms"} · ${_queryData.adults == 1 ? "1 adult" : "${_queryData.adults} adults"} · ${_queryData.children == 1 ? "1 child" : "${_queryData.children} children"}",
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),

        ElevatedButton.icon(
          onPressed: _navigateToResults,
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('Search', style: TextStyle(fontSize: 18)),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoCompleteSuggestions(double height, double width) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, height * 0.1, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        margin: const EdgeInsets.only(top: 8),
        constraints: const BoxConstraints(maxHeight: 250),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _autocompleteResults.length,
          itemBuilder: (context, index) {
            final item = _autocompleteResults[index];
            return ListTile(
              title: Text(item.valueToDisplay),
              subtitle: Text("${item.address.city}, ${item.address.state}"),
              onTap: () {
                setState(() {
                  _isSearching = false;
                });
                _selectSearchResult(item);
              },
            );
          },
        ),
      ),
    );
  }

  void _showGuestRoomBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Update Guests & Rooms',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const Divider(height: 20),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guests & Rooms',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildCounter(
                            'Rooms',
                            _queryData.rooms,
                            (val) =>
                                setModalState(() => _queryData.rooms = val),
                          ),
                          _buildCounter(
                            'Adults',
                            _queryData.adults,
                            (val) =>
                                setModalState(() => _queryData.adults = val),
                          ),
                          _buildCounter(
                            'Children',
                            _queryData.children,
                            (val) =>
                                setModalState(() => _queryData.children = val),
                            min: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateButton(BuildContext context, DateTime date, bool isCheckIn) {
    return InkWell(
      onTap: () => _selectDate(context, isCheckIn),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy').format(date),
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int min = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              _buildCounterButton(Icons.remove, () {
                if (value > min) onChanged(value - 1);
              }),
              SizedBox(
                width: 16,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              _buildCounterButton(Icons.add, () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 20, color: Colors.indigo),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'Loading authentication state...',
              style: TextStyle(color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
