
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/property.dart';
import 'package:mytravaly/domain/search.dart';
import 'package:mytravaly/presentation/search/results.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  SearchQueryData _queryData = SearchQueryData.initial();
  List<SearchResultItem> _autocompleteResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Implement debouncing for API call
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
    final visitorToken = Provider.of<AuthNotifier>(context, listen: false).visitorToken;

    if (visitorToken == null) return;
    
    final results = await _propertyService.searchAutoComplete(input, visitorToken);
    
    if (mounted) {
      setState(() {
        _autocompleteResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(SearchResultItem item) {
    setState(() {
      // 1. Update the criteria
      _queryData.searchType = item.searchType;
      _queryData.searchQuery = item.searchQuery;

      // 2. Update the text field for visual confirmation
      _searchController.text = item.valueToDisplay;
      
      // 3. Clear autocomplete results
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
          // Ensure checkout is after checkin
          if (_queryData.checkOut.isBefore(picked)) {
            _queryData.checkOut = picked.add(const Duration(days: 1));
          }
        } else {
          // Ensure checkout is not before checkin
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
        const SnackBar(content: Text('Please select a destination from the suggestions.'))
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          initialQuery: _queryData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destination'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Destination or Property Name',
                hintText: 'e.g., Hotel India, New Delhi',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _isSearching 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              ),
            ),
            
            // Autocomplete Results List
            if (_autocompleteResults.isNotEmpty)
              Container(
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
                      subtitle: Text(item.searchType.toUpperCase()),
                      onTap: () => _selectSearchResult(item),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            
            // Date Pickers
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateButton(context, 'Check-In', _queryData.checkIn, true),
                        _buildDateButton(context, 'Check-Out', _queryData.checkOut, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Room and Guest Counts
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Guests & Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildCounter('Rooms', _queryData.rooms, (val) => setState(() => _queryData.rooms = val)),
                    _buildCounter('Adults', _queryData.adults, (val) => setState(() => _queryData.adults = val)),
                    _buildCounter('Children', _queryData.children, (val) => setState(() => _queryData.children = val), min: 0),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Search Button
            ElevatedButton.icon(
              onPressed: _navigateToResults,
              icon: const Icon(Icons.hotel),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text('Search Hotels', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(BuildContext context, String label, DateTime date, bool isCheckIn) {
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context, isCheckIn),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged, {int min = 1}) {
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
              SizedBox(width: 16, child: Text(value.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))),
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
