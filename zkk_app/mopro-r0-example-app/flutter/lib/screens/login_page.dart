import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final LocalAuthentication _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  bool _deviceSupportsBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _checkDeviceSupport() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      setState(() {
        _deviceSupportsBiometrics = isAvailable;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _deviceSupportsBiometrics = false;
      });
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to log in',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (isAuthenticated && mounted) {
        final userId = await _storage.read(key: 'userId');
        final password = await _storage.read(key: 'password');
        
        if (userId != null && password != null) {
          _navigateToServices(userId, password);
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }
  
  Future<void> _loginWithPassword() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    final settings = Provider.of<SettingsModel>(context, listen: false);

    if (userId.isNotEmpty && password.isNotEmpty) {
      final isFirstLogin = !(await _storage.containsKey(key: 'userId'));
      
      await _storage.write(key: 'userId', value: userId);
      await _storage.write(key: 'password', value: password);
      
      if (isFirstLogin && _deviceSupportsBiometrics && mounted) {
        await _showBiometricSetupDialog(settings);
      } else {
        _navigateToServices(userId, password);
      }
    }
  }

  Future<void> _showBiometricSetupDialog(SettingsModel settings) async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: const Text('Would you like to use your fingerprint or Face ID for faster logins?'),
        actions: [
          TextButton(
            child: const Text('No, thanks'),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToServices(userId, password);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You can enable this any time in Settings.')),
              );
            },
          ),
          TextButton(
            child: const Text('Enable'),
            onPressed: () {
              settings.setBiometricEnabled(true);
              Navigator.of(context).pop();
              _navigateToServices(userId, password);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToServices(String userId, String password) {
    Navigator.pushNamed(context, '/services', arguments: {
      'userId': userId,
      'password': password,
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final bool shouldShowBiometricButton = _deviceSupportsBiometrics && settings.isBiometricEnabled;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to access services',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(labelText: 'User ID'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _loginWithPassword,
                    child: const Text('Login'),
                  ),
                  if (shouldShowBiometricButton) ...[
                    const SizedBox(height: 24.0),
                    OutlinedButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Biometric Login'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.brightness == Brightness.light
                              ? theme.colorScheme.onBackground
                              : theme.primaryColor,
                        ),
                        foregroundColor: theme.brightness == Brightness.light
                            ? theme.colorScheme.onBackground
                            : theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}