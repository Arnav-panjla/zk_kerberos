import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String serviceName;

  const WelcomePage({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to',
              style: theme.textTheme.headlineSmall,
            ),
            Text(
              serviceName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the services page
                Navigator.of(context).popUntil(ModalRoute.withName('/services'));
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}