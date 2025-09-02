import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usluga.dart';
import 'rezervacije_service.dart';

class UslugeService {
  final String baseUrl;
  UslugeService({required this.baseUrl});

  Future<List<Usluga>> fetchAll() async {
    final uri = Uri.parse('$baseUrl/api/usluge');
    final r = await http.get(uri, headers: {'Accept': 'application/json'});

    if (r.statusCode != 200) {
      throw ApiException(r.statusCode, r.body);
    }

    final data = jsonDecode(r.body);
    if (data is! List) {
      throw ApiException(500, 'Neočekivan format (očekivan je niz)');
    }

    return data.map<Usluga>((e) => Usluga.fromJson(e as Map<String, dynamic>)).toList();
  }
}
