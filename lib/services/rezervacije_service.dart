import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usluga.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => 'API $status: $message';
}

class ApiConflictException extends ApiException {
  ApiConflictException(String message) : super(409, message);
}

class RezervacijeService {
  final String baseUrl;
  RezervacijeService({required this.baseUrl});

  /// Kreiranje rezervacije
  Future<Map<String, dynamic>> create({
    required int saloonId,
    required String datumRezervacije,   // "yyyy-MM-dd"
    required String vrijemeRezervacije, // "HH:mm:00"
    required String userIme,
    required String userPrezime,
    required String kontaktTel,
    int? uslugaId,
  }) async {
    final uri = Uri.parse('$baseUrl/rezervacije');

    final body = <String, dynamic>{
      'saloon_id': saloonId,
      'datum_rezervacije': datumRezervacije,
      'vrijeme_rezervacije': vrijemeRezervacije,
      'user_ime': userIme,
      'user_prezime': userPrezime,
      'kontakt_tel': kontaktTel,
      if (uslugaId != null) 'usluga_id': uslugaId,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      try {
        final data = jsonDecode(resp.body);
        if (data is Map<String, dynamic>) return data;
      } catch (_) {}
      // Backend vratio plain text/ID
      return {'rezervacija_id': resp.body};
    }

    if (resp.statusCode == 409) {
      throw ApiConflictException(_extractMessage(resp));
    }

    if (resp.statusCode == 400 || resp.statusCode == 404) {
      throw ApiException(resp.statusCode, _extractMessage(resp));
    }

    throw ApiException(resp.statusCode, resp.body);
  }

  /// Dohvat svih usluga (GET /api/usluge)
  Future<List<Usluga>> fetchUsluge() async {
    final uri = Uri.parse('$baseUrl/api/usluge');
    final r = await http.get(uri, headers: {'Accept': 'application/json'});

    if (r.statusCode != 200) {
      throw ApiException(r.statusCode, _extractMessage(r));
    }

    final data = jsonDecode(r.body);
    if (data is! List) {
      throw ApiException(500, 'Neočekivan format (očekivan je niz)');
    }

    return data.map<Usluga>((e) => Usluga.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---------- Helper ----------

  String _extractMessage(http.Response r) {
    try {
      final parsed = jsonDecode(r.body);
      if (parsed is Map && parsed['message'] is String) {
        return parsed['message'] as String;
      }
      if (parsed is Map && parsed['error'] is String) {
        return parsed['error'] as String;
      }
    } catch (_) {}
    return 'Greška ${r.statusCode}';
  }
}
