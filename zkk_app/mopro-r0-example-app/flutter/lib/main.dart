import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mopro_flutter/mopro_flutter.dart';
import 'package:mopro_flutter/mopro_types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
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

  // Controllers for the three string input fields
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial text for the three fields (exactly 10 characters each)
    _userIdController.text = "user123456";
    _passwordController.text = "pass123456";
    _serviceIdController.text = "httpserver";

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
    _userIdController.dispose();
    _passwordController.dispose();
    _serviceIdController.dispose();
    _proveButtonController.dispose();
    _verifyButtonController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    final serviceId = _serviceIdController.text.trim();

    if (userId.length != 10) {
      return "User ID must be exactly 10 characters long (currently ${userId.length})";
    }
    if (password.length <= 8) {
      return "Password must be greater than 8 characters long (currently ${password.length})";
    }
    if (serviceId.length != 10) {
      return "Service ID must be exactly 10 characters long (currently ${serviceId.length})";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('zk-kerberos'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
              // User ID input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: "User ID",
                    hintText: "Enter User ID (exactly 10 characters)",
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                ),
              ),
              // Password input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Password (exactly 10 characters)",
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                  obscureText: true,
                ),
              ),
              // Service ID input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _serviceIdController,
                  decoration: const InputDecoration(
                    labelText: "Service ID",
                    hintText: "Enter Service ID (exactly 10 characters)",
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedBuilder(
                      animation: _proveButtonScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _proveButtonScale.value,
                          child: SizedBox(
                            width: 160,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: (_validateInputs() != null ||
                                      isProving ||
                                      isVerifying)
                                  ? null
                                  : () async {
                                      // Button press animation - complete before changing state
                                      await _proveButtonController.forward();
                                      await _proveButtonController.reverse();

                                      // Add haptic feedback
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        _error = null;
                                        isProving = true;
                                        _risc0VerifyResult =
                                            null; // Reset verify result
                                      });

                                      // Validate inputs first
                                      final validationError = _validateInputs();
                                      if (validationError != null) {
                                        setState(() {
                                          _error = Exception(validationError);
                                          isProving = false;
                                        });
                                        return;
                                      }

                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Risc0ProofOutput? risc0ProofResult;
                                      try {
                                        final userId =
                                            _userIdController.text.trim();
                                        final password =
                                            _passwordController.text.trim();
                                        final serviceId =
                                            _serviceIdController.text.trim();

                                        // Combine the three strings (you can modify this logic as needed)
                                        final combinedMessage =
                                            "$userId $serviceId $password";

                                        risc0ProofResult =
                                            await _moproFlutterPlugin
                                                .generateRisc0Proof(
                                                    combinedMessage);
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
                                    },
                              child: isProving
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Proving..."),
                                      ],
                                    )
                                  : const Text("Generate Proof"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedBuilder(
                      animation: _verifyButtonScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _verifyButtonScale.value,
                          child: SizedBox(
                            width: 160,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: (_risc0ProofResult != null &&
                                      !isProving &&
                                      !isVerifying)
                                  ? () async {
                                      // Button press animation - complete before changing state
                                      await _verifyButtonController.forward();
                                      await _verifyButtonController.reverse();

                                      // Add haptic feedback
                                      HapticFeedback.lightImpact();

                                      setState(() {
                                        _error = null;
                                        isVerifying = true;
                                      });

                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Risc0VerifyOutput? verifyResult;
                                      try {
                                        verifyResult = await _moproFlutterPlugin
                                            .verifyRisc0Proof(
                                                _risc0ProofResult!.receipt);
                                      } on Exception catch (e) {
                                        print("Error: $e");
                                        verifyResult = null;
                                        setState(() {
                                          _error = e;
                                        });
                                      }

                                      if (!mounted) return;

                                      setState(() {
                                        _risc0VerifyResult = verifyResult;
                                        isVerifying = false;
                                      });
                                    }
                                  : null,
                              child: isVerifying
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.green),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Verifying..."),
                                      ],
                                    )
                                  : const Text("Verify Proof"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_risc0ProofResult != null)
                AnimatedBuilder(
                  animation: _resultsFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _resultsFade.value,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Proof Generated Successfully!'),
                            const SizedBox(height: 8),
                            Text(
                                'Receipt size: ${(_risc0ProofResult!.receipt.length / 1024).toStringAsFixed(1)} KB'),
                            if (_risc0VerifyResult != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                  'Verification: ${_risc0VerifyResult!.isValid ? "PASSED" : "FAILED"}'),
                              const SizedBox(height: 4),
                              const Text('Verified Message:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  _risc0VerifyResult!.verifiedMessage,
                                  style:
                                      const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
