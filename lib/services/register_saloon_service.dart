import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saloon.dart';

class RegisterSaloonService {
  // Android emulator → API je na 10.0.2.2
  // Ako testiraš na fizičkom telefonu, stavi IP svog računara (npr. http://192.168.1.5:5029)
  final String baseUrl;

  RegisterSaloonService({required this.baseUrl});

  Future<Saloon> update(Saloon saloon) async {
    final uri = Uri.parse('$baseUrl/saloons/${saloon.saloonId}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saloon.toJson()),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Saloon.fromJson(data);
    } else {
      throw Exception('Greška ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Saloon> fetchById(int id) async {
    final uri = Uri.parse('$baseUrl/saloons/$id');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Saloon.fromJson(data);
    } else {
      throw Exception('Greška ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<List<Saloon>> search(String query) async {
    if (query.trim().length < 3) return [];
    final uri = Uri.parse('$baseUrl/saloons/search?q=${Uri.encodeQueryComponent(query)}');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});

    if (resp.statusCode == 200) {
      final list = (jsonDecode(resp.body) as List)
          .cast<Map<String, dynamic>>()
          .map((m) => Saloon.fromJson(m))
          .toList();
      return list;
    } else {
      throw Exception('Greška ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> deleteById(int id) async {
    final uri = Uri.parse('$baseUrl/saloons/$id');
    final resp = await http.delete(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Delete failed (${resp.statusCode}): ${resp.body}');
    }
  }


  Future<Saloon> register(Saloon saloon) async {
    final uri = Uri.parse('$baseUrl/saloons');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(saloon.toJson()),
    );

    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Saloon.fromJson(data);
    } else {
      throw Exception('Greška ${resp.statusCode}: ${resp.body}');
    }
  }
}
