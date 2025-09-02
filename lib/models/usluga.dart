class Usluga {
  final int id;
  final String naziv;
  final Duration? trajanje; // interval iz BE: "HH:mm:ss[.ffff]"
  final Duration? buffer;   // interval iz BE
  final bool? aktivno;

  Usluga({
    required this.id,
    required this.naziv,
    this.trajanje,
    this.buffer,
    this.aktivno,
  });

  factory Usluga.fromJson(Map<String, dynamic> j) {
    // ID: podrži uslugaId / usluga_id / id
    final rawId = j['uslugaId'] ?? j['usluga_id'] ?? j['id'];
    if (rawId == null) throw const FormatException('Usluga nema ID');
    final int id = rawId is int ? rawId : int.parse(rawId.toString());

    // Naziv
    final naziv = (j['naziv'] ?? j['name'] ?? '').toString();

    Duration? _parseInterval(dynamic v) {
      if (v == null) return null;
      if (v is String) {
        // očekujemo "HH:mm[:ss[.ffff]]"
        final p = v.split(':');
        if (p.length >= 2) {
          final h = int.tryParse(p[0]) ?? 0;
          final m = int.tryParse(p[1]) ?? 0;
          int s = 0;
          if (p.length >= 3) {
            final secStr = p[2].split('.').first;
            s = int.tryParse(secStr) ?? 0;
          }
          return Duration(hours: h, minutes: m, seconds: s);
        }
      }
      return null;
    }

    return Usluga(
      id: id,
      naziv: naziv,
      trajanje: _parseInterval(j['trajanje']),
      buffer: _parseInterval(j['buffer']),
      aktivno: j['aktivno'] is bool ? j['aktivno'] as bool : null,
    );
  }
}
