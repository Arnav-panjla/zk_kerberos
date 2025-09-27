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
  final TextEditingController _controllerField1 = TextEditingController();
  final TextEditingController _controllerField2 = TextEditingController();
  final TextEditingController _controllerField3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial text for the three fields
    _controllerField1.text = "Hello";
    _controllerField2.text = "World";
    _controllerField3.text = "ECDSA";

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
    _controllerField1.dispose();
    _controllerField2.dispose();
    _controllerField3.dispose();
    _proveButtonController.dispose();
    _verifyButtonController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mopro RISC0 ECDSA App'),
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
              // First string input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerField1,
                  decoration: const InputDecoration(
                    labelText: "First Message",
                    hintText: "Enter first part of message",
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              // Second string input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerField2,
                  decoration: const InputDecoration(
                    labelText: "Second Message",
                    hintText: "Enter second part of message",
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              // Third string input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerField3,
                  decoration: const InputDecoration(
                    labelText: "Third Message",
                    hintText: "Enter third part of message",
                  ),
                  keyboardType: TextInputType.text,
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
                              onPressed: (_controllerField1.text.trim().isEmpty || 
                                        _controllerField2.text.trim().isEmpty ||
                                        _controllerField3.text.trim().isEmpty ||
                                        isProving || isVerifying)
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
                                    _risc0VerifyResult = null; // Reset verify result
                                  });

                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Risc0ProofOutput? risc0ProofResult;
                                  try {
                                    final field1 = _controllerField1.text.trim();
                                    final field2 = _controllerField2.text.trim();
                                    final field3 = _controllerField3.text.trim();
                                    
                                    if (field1.isEmpty || field2.isEmpty || field3.isEmpty) {
                                      throw Exception("All fields must be filled");
                                    }
                                    
                                    // Combine the three strings (you can modify this logic as needed)
                                    final combinedMessage = "$field1 $field2 $field3";
                                    
                                    risc0ProofResult = await _moproFlutterPlugin.generateRisc0Proof(combinedMessage);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
                              onPressed: (_risc0ProofResult != null && !isProving && !isVerifying)
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

                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Risc0VerifyOutput? verifyResult;
                                  try {
                                    verifyResult = await _moproFlutterPlugin.verifyRisc0Proof(_risc0ProofResult!.receipt);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                            Text('Receipt size: ${(_risc0ProofResult!.receipt.length / 1024).toStringAsFixed(1)} KB'),
                            if (_risc0VerifyResult != null) ...[
                              const SizedBox(height: 16),
                              Text('Verification: ${_risc0VerifyResult!.isValid ? "PASSED" : "FAILED"}'),
                              const SizedBox(height: 4),
                              const Text('Verified Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  _risc0VerifyResult!.verifiedMessage,
                                  style: const TextStyle(fontFamily: 'monospace'),
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
