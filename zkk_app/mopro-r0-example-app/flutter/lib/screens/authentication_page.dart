import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mopro_flutter/mopro_flutter.dart';
import 'package:mopro_flutter/mopro_types.dart';

class AuthenticatePage extends StatefulWidget {
  final String userId;
  final String password;
  final Map<String, String> service;

  const AuthenticatePage({
    super.key,
    required this.userId,
    required this.password,
    required this.service,
  });

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage>
    with TickerProviderStateMixin {
  Risc0ProofOutput? _risc0ProofResult;
  Risc0VerifyOutput? _risc0VerifyResult;
  final _moproFlutterPlugin = MoproFlutter();
  bool isProving = false;
  bool isVerifying = false;
  Exception? _error;
  late AnimationController _proveButtonController;
  late AnimationController _verifyButtonController;
  late AnimationController _resultsFadeController;
  late Animation<double> _proveButtonScale;
  late Animation<double> _verifyButtonScale;
  late Animation<double> _resultsFade;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _proveButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _verifyButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _resultsFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _proveButtonScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _proveButtonController, curve: Curves.easeOut),
    );
    _verifyButtonScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _verifyButtonController, curve: Curves.easeOut),
    );
    _resultsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultsFadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _proveButtonController.dispose();
    _verifyButtonController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  Future<void> _generateProof() async {
    // Button press animation
    await _proveButtonController.forward();
    await _proveButtonController.reverse();

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _error = null;
      isProving = true;
      _risc0ProofResult = null;
      _risc0VerifyResult = null; // Reset verify result
    });

    FocusManager.instance.primaryFocus?.unfocus();
    Risc0ProofOutput? risc0ProofResult;
    try {
      final serviceId = "httpserver"; // As per original logic
      final combinedMessage = "${widget.userId} $serviceId ${widget.password}";

      risc0ProofResult =
          await _moproFlutterPlugin.generateRisc0Proof(combinedMessage);
    } on Exception catch (e) {
      print("Error: $e");
      risc0ProofResult = null;
      setState(() {
        _error = e;
      });
    }

    if (!mounted) return;

    setState(() {
      isProving = false;
      _risc0ProofResult = risc0ProofResult;
    });

    // Animate results fade in
    if (risc0ProofResult != null) {
      _resultsFadeController.forward();
    }
  }

  void _connectToService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully connected to ${widget.service['name']}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isProofGenerated = _risc0ProofResult != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.service['name']!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // The Text widget for the description has been removed.
            const SizedBox(height: 40),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _error.toString(),
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _proveButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _proveButtonScale.value,
                  child: ElevatedButton.icon(
                    onPressed: isProving ? null : _generateProof,
                    icon: isProving
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.gpp_good_outlined),
                    label: Text(isProving ? 'Generating...' : 'Generate Proof'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            if (_risc0ProofResult != null)
              AnimatedBuilder(
                animation: _resultsFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _resultsFade.value,
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Proof Generated Successfully!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isProofGenerated ? _connectToService : null,
              icon: const Icon(Icons.link),
              label: const Text('Connect'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isProofGenerated ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}