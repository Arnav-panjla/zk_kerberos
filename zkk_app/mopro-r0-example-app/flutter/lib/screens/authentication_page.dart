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
  final _moproFlutterPlugin = MoproFlutter();
  bool isProving = false;
  Exception? _error;
  late AnimationController _proveButtonController;
  late AnimationController _resultsFadeController;

  @override
  void initState() {
    super.initState();
    _proveButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _resultsFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _proveButtonController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  Future<void> _generateProof() async {
    await _proveButtonController.forward();
    await _proveButtonController.reverse();
    HapticFeedback.lightImpact();

    setState(() {
      _error = null;
      isProving = true;
      _risc0ProofResult = null;
      _resultsFadeController.reset();
    });

    try {
      final serviceId = "httpserver";
      final combinedMessage = "${widget.userId} $serviceId ${widget.password}";
      final risc0ProofResult =
          await _moproFlutterPlugin.generateRisc0Proof(combinedMessage);

      if (!mounted) return;
      setState(() {
        _risc0ProofResult = risc0ProofResult;
      });
      _resultsFadeController.forward();

    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    } finally {
       if (!mounted) return;
      setState(() {
        isProving = false;
      });
    }
  }

  void _connectToService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully connected to ${widget.service['name']}!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isProofGenerated = _risc0ProofResult != null;
    final theme = Theme.of(context);

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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a proof to connect securely.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 40),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade200),
                ),
              ),
            ElevatedButton.icon(
              onPressed: isProving ? null : _generateProof,
              icon: isProving
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.shield_outlined),
              label: Text(isProving ? 'Generating Proof...' : 'Generate Proof'),
            ),
            const SizedBox(height: 24),
            if (_risc0ProofResult != null)
              FadeTransition(
                opacity: _resultsFadeController,
                child: Card(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Proof Generated Successfully!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isProofGenerated ? _connectToService : null,
              icon: const Icon(Icons.link),
              label: const Text('Connect'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isProofGenerated ? theme.primaryColor : Colors.grey.shade800,
                ),
                foregroundColor: isProofGenerated ? theme.primaryColor : Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}