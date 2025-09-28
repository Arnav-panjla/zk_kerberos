import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<String> _allServices = const [
    'Webmail',
    'Gradescope',
    'Library',
    'WiFi Access',
    'Badal VM',
    'Moodle',
    'Admin Login',
  ];

  List<String> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredServices = _allServices;
    _searchController.addListener(_filterServices);
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;
        return;
      }

      var filtered = _allServices
          .where((service) => service.toLowerCase().contains(query))
          .toList();

      if (filtered.isEmpty) {
        final bestMatch = query.bestMatch(_allServices);
        if (bestMatch.bestMatch.rating != null && bestMatch.bestMatch.rating! > 0.3) {
          filtered = [bestMatch.bestMatch.target!];
        } else {
          filtered = [];
        }
      }
      _filteredServices = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final userId = loginArgs['userId']!;
    final password = loginArgs['password']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a service...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          if (_filteredServices.isEmpty && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No services found.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final serviceName = _filteredServices[index];
                return _buildAnimatedListItem(context, index, serviceName, userId, password);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListItem(BuildContext context, int index, String serviceName, String userId, String password) {
    String avatarText = serviceName.isNotEmpty ? serviceName[0] : '';
    if (serviceName.contains(' ')) {
      final parts = serviceName.split(' ');
      avatarText = parts[0][0] + (parts.length > 1 ? parts[1][0] : '');
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              avatarText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            serviceName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade600,
            size: 18,
          ),
          onTap: () {
            // CORRECTED THE ROUTE NAME HERE
            Navigator.pushNamed(
              context,
              '/authentication',
              arguments: {
                'userId': userId,
                'password': password,
                'service': {'name': serviceName},
              },
            );
          },
        ),
      ),
    );
  }
}