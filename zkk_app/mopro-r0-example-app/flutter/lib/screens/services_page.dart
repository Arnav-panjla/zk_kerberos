import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});

  // Simplified the list to only contain the service names.
  final List<String> services = const [
    'Service 1',
    'Service 2',
    'Service 3',
  ];

  @override
  Widget build(BuildContext context) {
    final loginArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final userId = loginArgs['userId']!;
    final password = loginArgs['password']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final serviceName = services[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(serviceName.split(' ').last),
              ),
              title: Text(serviceName),
              // The subtitle has been removed.
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/authenticate',
                  arguments: {
                    'userId': userId,
                    'password': password,
                    // Pass the service name in the required map structure.
                    'service': {'name': serviceName},
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}