import 'package:flutter/material.dart';
import 'package:mytravaly/data/provider/auth.dart';
import 'package:mytravaly/data/service/property.dart';
import 'package:mytravaly/domain/property.dart';
import 'package:mytravaly/presentation/home/widgets/card.dart';
import 'package:mytravaly/presentation/search/search.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to delay fetch until build context is available
    Future.microtask(() => _fetchProperties());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Stays in Jamshedpur (Page 2)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(property: _properties[index]);
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
        },
        label: const Text('Search Hotels'),
        icon: const Icon(Icons.search),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
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
