import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResult {
  final int saloonId;
  final String nazivSalona;
  final String email;
  final String adminIme;

  AuthResult({
    required this.saloonId,
    required this.nazivSalona,
    required this.email,
    required this.adminIme,
  });

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
    saloonId: j['saloonId'] as int,
    nazivSalona: j['nazivSalona'] as String,
    email: j['email'] as String,
    adminIme: j['adminIme'] as String,
  );
}

class AuthService {
  final String baseUrl; // npr. http://10.0.2.2:5029
  AuthService({required this.baseUrl});

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception('Login failed (${res.statusCode}): ${res.body}');
    }
    return AuthResult.fromJson(jsonDecode(res.body));
  }
}
