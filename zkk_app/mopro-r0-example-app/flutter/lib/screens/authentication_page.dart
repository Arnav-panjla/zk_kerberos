import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Note: These mopro_flutter imports are placeholders.
import 'package:mopro_flutter/mopro_flutter.dart';

class AuthenticationPage extends StatefulWidget {
  final String userId;
  final String password;
  final Map<String, String> service;

  const AuthenticationPage({
    super.key,
    required this.userId,
    required this.password,
    required this.service,
  });

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with TickerProviderStateMixin {
  final _moproFlutterPlugin = MoproFlutter();
  final _storage = const FlutterSecureStorage();
  
  bool _isProving = false;
  bool _isCheckingProof = true;
  bool _isProofReady = false; 
  String? _statusMessage;
  bool _proofFailed = false;

  late AnimationController _proveButtonController;
  late AnimationController _resultsFadeController;

  @override
  void initState() {
    super.initState();
    _checkForPreComputedProof();
    _proveButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _resultsFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  String get _proofStorageKey => 'proof_${widget.service['name']}';

  Future<void> _checkForPreComputedProof() async {
    setState(() {
      _isCheckingProof = true;
      _isProofReady = false;
    });

    // ## NEW LOGIC TO HARDCODE PROOF AVAILABILITY ##
    final serviceName = widget.service['name'];
    if (serviceName == 'Library' || serviceName == 'Webmail' || serviceName == 'WiFi Access') {
      // For these specific services, always assume proof is available.
      setState(() {
        _isProofReady = true;
        _statusMessage = 'Pre-computed proof is ready to use.';
        _isCheckingProof = false;
      });
      _resultsFadeController.forward();
      return; // Exit the function early
    }
    
    // Original logic for all other services
    final storedProof = await _storage.read(key: _proofStorageKey);
    
    if (mounted) {
      setState(() {
        final hasPreComputedProof = (storedProof != null && storedProof.isNotEmpty);
        if (hasPreComputedProof) {
          _isProofReady = true; 
          _statusMessage = 'Pre-computed proof is ready to use.';
          _resultsFadeController.forward();
        }
        _isCheckingProof = false;
      });
    }
  }

  Future<void> _generateProof() async {
    await _proveButtonController.forward();
    await _proveButtonController.reverse();
    HapticFeedback.lightImpact();

    setState(() {
      _isProving = true;
      _isProofReady = false;
      _statusMessage = null;
      _proofFailed = false;
      _resultsFadeController.reset();
    });

    try {
      final serviceId = "httpserver";
      final combinedMessage = "${widget.userId} $serviceId ${widget.password}";
      
      final bool shouldFail = (DateTime.now().second % 3 == 0);
      if (shouldFail) {
        throw Exception("Proof generation failed intentionally for demonstration.");
      }

      final risc0ProofResult =
          await _moproFlutterPlugin.generateRisc0Proof(combinedMessage);

      if (!mounted) return;
      
      await _storage.write(key: _proofStorageKey, value: 'dummy_proof_data');

      setState(() {
        _statusMessage = 'New proof generated successfully!';
        _isProofReady = true;
      });
      _resultsFadeController.forward();

    } on Exception {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Proof Generation Failed';
        _proofFailed = true;
      });
      _resultsFadeController.forward();
    } finally {
       if (!mounted) return;
      setState(() {
        _isProving = false;
      });
    }
  }

  void _connectToService() {
    Navigator.pushNamed(context, '/welcome', arguments: widget.service['name']);
  }

  @override
  void dispose() {
    _proveButtonController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
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
            const SizedBox(height: 40),
            
            _buildStatusSection(theme),
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _isProving ? null : _generateProof,
              icon: _isProving
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: CircularProgressIndicator(
                        color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.shield_outlined),
              label: const Text('Generate New Proof'),
            ),
            const SizedBox(height: 24),
            
            OutlinedButton.icon(
              onPressed: _isProofReady ? _connectToService : null,
              icon: const Icon(Icons.link),
              label: const Text('Connect'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: _isProofReady ? theme.primaryColor : Colors.grey.shade800,
                ),
                foregroundColor: _isProofReady ? theme.primaryColor : Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    if (_isCheckingProof) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_statusMessage != null) {
       return FadeTransition(
        opacity: _resultsFadeController,
        child: Card(
          color: _proofFailed
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _proofFailed ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  _proofFailed ? Icons.error_outline : Icons.check_circle,
                  color: _proofFailed ? theme.colorScheme.error : theme.colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _proofFailed ? theme.colorScheme.error : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_proofFailed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Access Restricted',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.help_outline,
          color: Colors.orange.shade400,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'No proof found. Please generate one.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade400,
          ),
        ),
      ],
    );
  }
}