import 'dart:convert';
import 'package:http/http.dart' as http;

class SaloonDetails {
  final int saloonId;
  final String nazivSalona;
  final String? logo;          // npr. URL string ili null
  final String? radnoVrijeme;  // npr. "09:00 - 17:00" ili null

  SaloonDetails({
    required this.saloonId,
    required this.nazivSalona,
    this.logo,
    this.radnoVrijeme,
  });

  factory SaloonDetails.fromJson(Map<String, dynamic> j) => SaloonDetails(
    saloonId: (j['saloonId'] as num).toInt(),
    nazivSalona: j['nazivSalona'] as String,
    logo: j['logo'] as String?,
    radnoVrijeme: j['radnoVrijeme'] as String?,
  );
}

class SaloonService {
  final String baseUrl; // npr. http://10.0.2.2:5029
  SaloonService({required this.baseUrl});

  Future<SaloonDetails> getById(int id) async {
    final uri = Uri.parse('$baseUrl/saloons/$id');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('GET /saloons/$id failed (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return SaloonDetails.fromJson(data);
  }
}
