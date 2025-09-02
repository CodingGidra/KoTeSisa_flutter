import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/slot_grid.dart';
import '../services/rezervacije_service.dart';
import '../models/usluga.dart';
import '../services/usluge_service.dart';


class SubmitTerminScreen extends StatefulWidget {
  const SubmitTerminScreen({super.key});

  @override
  State<SubmitTerminScreen> createState() => _SubmitTerminScreenState();
}

class _SubmitTerminScreenState extends State<SubmitTerminScreen> {
  static const Duration _korak = Duration(minutes: 15);

  int? _saloonId;
  String _nazivSalona = 'Rezervacija';
  TimeOfDay? _radnoOd;
  TimeOfDay? _radnoDo;


  final Map<String, Set<String>> _zauzetoPoDanu = {
    _fmtDatum(DateTime.now()): {'10:30', '11:10'},
    _fmtDatum(DateTime.now().add(const Duration(days: 1))): {'13:30'},
  };

  final DateTime _danas = _bezVremena(DateTime.now());
  late DateTime _odabraniDatum = _danas;

  DateTime _mjesecStart = DateTime(DateTime.now().year, DateTime.now().month, 1);

  TimeOfDay? _odabranoVrijeme;

  // --- Dinamičke usluge iz API-ja ---
  List<Usluga> _usluge = [];
  bool _loadingUsluge = false;
  String? _uslugeError;
  bool _uslugeUcitanJednom = false;

  Future<void> _ucitajUsluge() async {
    setState(() {
      _loadingUsluge = true;
      _uslugeError = null;
    });
    try {
      final svc = UslugeService(baseUrl: 'http://10.0.2.2:5029');
      final list = await svc.fetchAll();
      if (!mounted) return;
      setState(() {
        _usluge = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uslugeError = '$e');
    } finally {
      if (mounted) setState(() => _loadingUsluge = false);
    }
  }


  // ---------- POPUP FORMA + SUBMIT ----------
  Future<void> _otvoriPopupRezervacija() async {
    // Ako usluge nisu učitane, učitaj sada (da izbjegnemo prazan popup)
    if (_usluge.isEmpty && !_loadingUsluge) {
      await _ucitajUsluge();
    }

    final formKey = GlobalKey<FormState>();
    final imeCtrl = TextEditingController();
    final prezimeCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    int? uslugaId = (_usluge.isNotEmpty) ? _usluge.first.id : null;
    bool submitting = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Podaci za termin'),
        content: StatefulBuilder(
          builder: (ctx, setSBState) => SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: imeCtrl,
                    decoration: const InputDecoration(labelText: 'Ime'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite ime' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: prezimeCtrl,
                    decoration: const InputDecoration(labelText: 'Prezime'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite prezime' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Kontakt telefon'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Unesite telefon' : null,
                  ),
                  const SizedBox(height: 12),

                  // Usluge
                  if (_loadingUsluge) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Učitavam usluge...'),
                  ] else if (_uslugeError != null) ...[
                    Text(_uslugeError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          setSBState(() => _loadingUsluge = true);
                          await _ucitajUsluge();
                          // osvježi prikaz u popupu
                          setSBState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Pokušaj opet'),
                      ),
                    ),
                  ] else if (_usluge.isEmpty) ...[
                    // Ako API vrati 200, ali nema usluga:
                    const Text('Nema definisanih usluga.'),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          setSBState(() => _loadingUsluge = true);
                          await _ucitajUsluge();
                          setSBState(() {});
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Osvježi'),
                      ),
                    ),
                  ] else ...[
                    DropdownButtonFormField<int>(
                      value: uslugaId,
                      decoration: const InputDecoration(labelText: 'Usluga'),
                      items: _usluge
                          .map<DropdownMenuItem<int>>(
                            (u) => DropdownMenuItem<int>(
                          value: u.id,
                          child: Text(u.naziv),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setSBState(() => uslugaId = v),
                      validator: (v) => v == null ? 'Odaberite uslugu' : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: submitting
                ? null
                : () {
              Navigator.of(ctx).pop(false);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                imeCtrl.dispose();
                prezimeCtrl.dispose();
                telCtrl.dispose();
              });
            },
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: submitting
                ? null
                : () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              if (_saloonId == null || _odabranoVrijeme == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nedostaju podaci o salonu ili terminu')),
                );
                return;
              }
              if (_usluge.isEmpty || uslugaId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Odaberite uslugu')),
                );
                return;
              }

              setState(() => submitting = true);

              final svc = RezervacijeService(baseUrl: 'http://10.0.2.2:5029');
              try {
                final res = await svc.create(
                  saloonId: _saloonId!,
                  datumRezervacije: _fmtDatum(_odabraniDatum), // 'yyyy-MM-dd'
                  vrijemeRezervacije: '${_fmtHm(_odabranoVrijeme!)}:00', // 'HH:mm:00'
                  userIme: imeCtrl.text.trim(),
                  userPrezime: prezimeCtrl.text.trim(),
                  kontaktTel: telCtrl.text.trim(),
                  uslugaId: uslugaId,
                );

                Navigator.of(ctx).pop(true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  imeCtrl.dispose();
                  prezimeCtrl.dispose();
                  telCtrl.dispose();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res.containsKey('rezervacija_id')
                          ? 'Termin potvrđen (ID: ${res['rezervacija_id']})'
                          : 'Termin potvrđen',
                    ),
                  ),
                );
              } on ApiConflictException catch (e) {
                setState(() => submitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              } catch (e) {
                setState(() => submitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Greška: $e')),
                );
              }
            },
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (ok == true) {
      // po želji: refresh zauzeća
    }
  }
  // ---------- /POPUP FORMA + SUBMIT ----------

  // ----- helperi -----
  static String _fmtDatum(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String _fmtHm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  static DateTime _bezVremena(DateTime d) => DateTime(d.year, d.month, d.day);

  static TimeOfDay _parseHmOrHms(String s) {
    final p = s.split(':'); // "HH:mm" ili "HH:mm:ss"
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  int _uMinute(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _izMinuta(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

  bool _istiDan(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _uProslostiDanas(DateTime dan, TimeOfDay slot) {
    final sada = DateTime.now();
    if (!_istiDan(dan, sada)) return false;
    return _uMinute(slot) <= _uMinute(TimeOfDay.fromDateTime(sada));
  }

  // --- pomoćne za kalendar ---
  DateTime _pocetakPrikazaMjeseca(DateTime monthStart) {
    final wd = monthStart.weekday; // Mon=1..Sun=7
    return monthStart.subtract(Duration(days: wd - 1));
  }

  List<DateTime> _daniZaGrid(DateTime monthStart) {
    final start = _pocetakPrikazaMjeseca(monthStart);
    return List.generate(42, (i) => start.add(Duration(days: i))); // 6x7
  }

  bool _jeProsao(DateTime d) => d.isBefore(_danas);
  bool _jeIstiMjesec(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;
  DateTime _dodajMjesece(DateTime d, int m) => DateTime(d.year, d.month + m, 1);

  // slotovi: prvi = tačno radnoVrijemeOd
  List<TimeOfDay> _generisiSlotove() {
    final od = _radnoOd;
    final d0 = _radnoDo;
    if (od == null || d0 == null) return const [];
    if (_uMinute(od) >= _uMinute(d0)) return const [];

    final out = <TimeOfDay>[];
    var cur = od;
    final endM = _uMinute(d0);

    while (_uMinute(cur) < endM) {
      out.add(cur);
      cur = _izMinuta(_uMinute(cur) + _korak.inMinutes);
    }
    return out;
  }

  bool _jeZauzet(DateTime dan, TimeOfDay t) {
    final set = _zauzetoPoDanu[_fmtDatum(dan)];
    return set?.contains(_fmtHm(t)) ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final dynamicId = args['saloonId'];
      if (dynamicId is int) _saloonId = dynamicId;
      if (dynamicId is String) _saloonId = int.tryParse(dynamicId);

      final naziv = args['nazivSalona'] as String?;
      final od = args['radnoVrijemeOd'] as String?;
      final doo = args['radnoVrijemeDo'] as String?;

      if (naziv != null && naziv.isNotEmpty) _nazivSalona = naziv;
      _radnoOd = (od != null && od.isNotEmpty) ? _parseHmOrHms(od) : null;
      _radnoDo = (doo != null && doo.isNotEmpty) ? _parseHmOrHms(doo) : null;
    }

    if (_saloonId != null && !_uslugeUcitanJednom) {
      _uslugeUcitanJednom = true;
      _ucitajUsluge();
    }
  }

  @override
  Widget build(BuildContext context) {
    const pozadina = Color(0xFFE9F2FA);
    const primarna = Color(0xFF2458E6);

    final slotovi = _generisiSlotove();
    final nemaRadno = _radnoOd == null || _radnoDo == null;
    final nemaSlotova = slotovi.isEmpty;

    final prosliSet = slotovi
        .where((t) => _uProslostiDanas(_odabraniDatum, t))
        .map(_fmtHm)
        .toSet();

    final zauzetiSet = {
      ...(_zauzetoPoDanu[_fmtDatum(_odabraniDatum)] ?? const <String>{}),
      ...prosliSet,
    };

    final otvorenoInfo = (!nemaRadno)
        ? 'Otvoreno: ${_fmtHm(_radnoOd!)} – ${_fmtHm(_radnoDo!)}'
        : 'Radno vrijeme nije postavljeno';

    final gridDani = _daniZaGrid(_mjesecStart);
    final danasnjaJeUAktivnom = _jeIstiMjesec(_danas, _mjesecStart);
    final mozeNazad = !(_mjesecStart.year == _danas.year && _mjesecStart.month == _danas.month);
    final mozeNaprijed = true;

    return Scaffold(
      backgroundColor: pozadina,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _nazivSalona,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header mjeseca + navigacija
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Prethodni mjesec',
                  onPressed: mozeNazad
                      ? () {
                    setState(() {
                      _mjesecStart = _dodajMjesece(_mjesecStart, -1);
                      if (_mjesecStart.isBefore(DateTime(_danas.year, _danas.month, 1))) {
                        _mjesecStart = DateTime(_danas.year, _danas.month, 1);
                      }
                    });
                  }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat.yMMMM().format(_mjesecStart),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sljedeći mjesec',
                  onPressed: mozeNaprijed
                      ? () {
                    setState(() {
                      _mjesecStart = _dodajMjesece(_mjesecStart, 1);
                    });
                  }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // nazivi dana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DanLabel('Pon'),
                _DanLabel('Uto'),
                _DanLabel('Sri'),
                _DanLabel('Čet'),
                _DanLabel('Pet'),
                _DanLabel('Sub'),
                _DanLabel('Ned'),
              ],
            ),
          ),

          // mjesečni grid (6x7)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridDani.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (_, i) {
                final d = gridDani[i];
                final uAktivnom = _jeIstiMjesec(d, _mjesecStart);
                final disabled = _jeProsao(d);
                final isToday = _istiDan(d, _danas);
                final isSelected = _istiDan(d, _odabraniDatum);

                final tappable = !disabled && uAktivnom;

                Color fg = Colors.black87;
                double opacity = uAktivnom ? 1.0 : 0.40;

                BoxDecoration deco;
                if (isSelected) {
                  deco = BoxDecoration(color: primarna, shape: BoxShape.circle);
                  fg = Colors.white;
                } else if (isToday && danasnjaJeUAktivnom && uAktivnom) {
                  deco = BoxDecoration(
                    border: Border.all(color: primarna, width: 1.5),
                    shape: BoxShape.circle,
                    color: Colors.white,
                  );
                } else {
                  deco = const BoxDecoration(color: Colors.white, shape: BoxShape.circle);
                }

                if (disabled) opacity = 0.30;

                return Opacity(
                  opacity: opacity,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: tappable
                        ? () {
                      setState(() {
                        _odabraniDatum = _bezVremena(d);
                        _odabranoVrijeme = null;
                      });
                    }
                        : null,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: deco,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Info o radnom vremenu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              otvorenoInfo,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),

          // Naslov “Termini”
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Termini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          // Grid termina
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: nemaRadno
                  ? const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nema radnog vremena za prikaz.',
                    style: TextStyle(color: Colors.black54)),
              )
                  : (nemaSlotova
                  ? const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nema termina u zadatom radnom vremenu.',
                    style: TextStyle(color: Colors.black54)),
              )
                  : SlotGrid(
                slots: slotovi,
                bookedHmSet: zauzetiSet,
                selected: _odabranoVrijeme,
                primary: primarna,
                onSelect: (t) {
                  if (_uProslostiDanas(_odabraniDatum, t)) return;
                  if (_jeZauzet(_odabraniDatum, t)) return;
                  setState(() => _odabranoVrijeme = t);
                },
              )),
            ),
          ),

          // Potvrda (otvara popup formu)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2458E6),
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (nemaRadno || _odabranoVrijeme == null) ? null : _otvoriPopupRezervacija,
                child: const Text('Potvrdi termin'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Pomoćni mali widget za labelu dana ---
class _DanLabel extends StatelessWidget {
  final String text;
  const _DanLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ),
    );
  }
}
