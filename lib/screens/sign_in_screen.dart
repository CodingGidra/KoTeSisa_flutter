import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'saloon_details_screen.dart';
import '../services/saloon_service.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();
  bool _obscure = true;

  // Android emulator -> 10.0.2.2; iOS sim/desktop -> localhost; fizički tel -> IP PC-a
  final _auth = AuthService(baseUrl: 'http://10.0.2.2:5029');
  final _saloonService = SaloonService(baseUrl: 'http://10.0.2.2:5029');


  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _pwC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // 1) prvo login
      final res = await _auth.signIn(
        email: _emailC.text.trim(),
        password: _pwC.text,
      );

// 2) zatim GET salona po id-u
      final details = await _saloonService.getById(res.saloonId);

// 3) navigacija sa pravim podacima
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SaloonDetailsScreen(
            saloonId: details.saloonId,
            adminIme: res.adminIme,
            nazivSalona: details.nazivSalona,
            logoUrl: details.logo,
            radnoVrijeme: details.radnoVrijeme,
            isAdmin: true,
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // crna pozadina
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text('Sign in (Admin)'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900], // tamno siva kartica
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailC,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Unesi validan email' : null,
                    ),
                    const SizedBox(height: 12),
                    // Password
                    TextFormField(
                      controller: _pwC,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 karaktera' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
