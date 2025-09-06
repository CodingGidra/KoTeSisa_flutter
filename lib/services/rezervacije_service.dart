import 'dart:convert';
import 'package:http/http.dart' as http;

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

  /// Kreiranje rezervacije (POST /rezervacije)
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

  /// Detalji slotova (GET /rezervacije/slotovi)
  /// Vraća mapu sa dva seta stringova "HH:mm":
  ///  - 'zauzeti'            → slotovi koji su zauzeti (po koraku, npr. 15 min)
  ///  - 'dodatni_startovi'   → tačni krajevi rezervacija (npr. "12:20")
  Future<Map<String, Set<String>>> fetchSlotoviDetalji({
    required int saloonId,
    required String datum, // "yyyy-MM-dd"
    required String od,    // "HH:mm"
    required String doo,   // "HH:mm"  // query param je 'do'
    int korak = 15,
  }) async {
    final uri = Uri.parse('$baseUrl/rezervacije/slotovi').replace(queryParameters: {
      'saloon_id': saloonId.toString(),
      'datum': datum,
      'od': od,
      'do': doo,
      'korak': korak.toString(),
    });

    final r = await http.get(uri, headers: {'Accept': 'application/json'});
    if (r.statusCode != 200) {
      throw ApiException(r.statusCode, _extractMessage(r));
    }

    final data = jsonDecode(r.body);
    if (data is! Map<String, dynamic>) {
      throw ApiException(500, 'Neočekivan format (očekivan je objekat)');
    }

    // Zauzeti slotovi po koraku
    final List slotovi = data['slotovi'] as List? ?? const [];
    final Set<String> zauzeti = {
      for (final s in slotovi)
        if (s is Map && s['zauzet'] == true && s['vrijeme'] is String)
          (s['vrijeme'] as String)
    };

    // Dodatni startovi = krajevi rezervacija
    final List dodatni = data['dodatni_startovi'] as List? ?? const [];
    final Set<String> dodatniStartovi = {
      for (final s in dodatni)
        if (s is String) s
    };

    return {
      'zauzeti': zauzeti,
      'dodatni_startovi': dodatniStartovi,
    };
  }

  /// Zauzeti slotovi (SET "HH:mm") — koristi detalje i vraća samo zauzete
  Future<Set<String>> fetchZauzetiSlotoviHmSet({
    required int saloonId,
    required String datum, // "yyyy-MM-dd"
    required String od,    // "HH:mm"
    required String doo,   // "HH:mm"
    int korak = 15,
  }) async {
    final det = await fetchSlotoviDetalji(
      saloonId: saloonId,
      datum: datum,
      od: od,
      doo: doo,
      korak: korak,
    );
    return det['zauzeti'] ?? <String>{};
  }

  /// Kompatibilni wrapper (cijeli dan → vraća samo zauzete)
  Future<Set<String>> fetchBookedHmSet({
    required int saloonId,
    required String datum, // "yyyy-MM-dd"
  }) {
    return fetchZauzetiSlotoviHmSet(
      saloonId: saloonId,
      datum: datum,
      od: '00:00',
      doo: '23:45',
      korak: 15,
    );
  }

  // ----------------- Helper -----------------

  String _extractMessage(http.Response r) {
    try {
      final parsed = jsonDecode(r.body);
      if (parsed is Map) {
        if (parsed['poruka'] is String) return parsed['poruka'] as String;   // bosanski ključ
        if (parsed['message'] is String) return parsed['message'] as String; // engleski ključ
        if (parsed['error'] is String) return parsed['error'] as String;
      }
    } catch (_) {}
    return 'Greška ${r.statusCode}';
  }
}
