import 'package:flutter/material.dart';
import '../models/saloon.dart';
import '../services/register_saloon_service.dart';

class RegisterSaloonScreen extends StatefulWidget {
  final Saloon? saloon;
  final bool isEdit;

  const RegisterSaloonScreen({super.key, this.saloon, this.isEdit = false});

  @override
  State<RegisterSaloonScreen> createState() => _RegisterSaloonScreenState();
}

class _RegisterSaloonScreenState extends State<RegisterSaloonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nazivCtl = TextEditingController();
  final _ulicaCtl = TextEditingController();
  final _brojCtl = TextEditingController();
  final _gradCtl = TextEditingController();
  final _postanskiCtl = TextEditingController();
  final _lokacijaCtl = TextEditingController();
  final _telefonCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _radnoCtl = TextEditingController();
  final _logoCtl = TextEditingController();
  final _adminImeCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  TimeOfDay? _vrijemeOd;
  TimeOfDay? _vrijemeDo;

  // Emulator: http://10.0.2.2:5029 | Desktop/iOS sim: http://localhost:5029 | Fizični tel: http://<IP_PC>:5029
  final RegisterSaloonService _service =
  RegisterSaloonService(baseUrl: 'http://10.0.2.2:5029');

  // ---- helpers za konverziju ----
  TimeOfDay? _parseHHmmss(String? v) {
    if (v == null || v.isEmpty) return null;
    final parts = v.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmtHHmmss(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
  // --------------------------------

  @override
  void initState() {
    super.initState();
    final s = widget.saloon;
    if (widget.isEdit && s != null) {
      _nazivCtl.text = s.nazivSalona;
      _ulicaCtl.text = s.adresaUlica;
      _brojCtl.text = s.adresaBroj ?? '';
      _gradCtl.text = s.grad;
      _postanskiCtl.text = s.postanskiBroj ?? '';
      _lokacijaCtl.text = s.lokacija ?? '';
      _telefonCtl.text = s.brojTelefona;
      _emailCtl.text = s.email;
      _adminImeCtl.text = s.adminIme;
      _passwordCtl.text = s.password;
      _logoCtl.text = s.logo ?? '';
      _vrijemeOd = _parseHHmmss(s.radnoVrijemeOd);
      _vrijemeDo = _parseHHmmss(s.radnoVrijemeDo);
    }
  }

  @override
  void dispose() {
    _nazivCtl.dispose();
    _ulicaCtl.dispose();
    _brojCtl.dispose();
    _gradCtl.dispose();
    _postanskiCtl.dispose();
    _lokacijaCtl.dispose();
    _telefonCtl.dispose();
    _emailCtl.dispose();
    _radnoCtl.dispose();
    _logoCtl.dispose();
    _adminImeCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obavezno polje' : null;

  InputDecoration _dec(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  Future<void> _birajVrijemeOd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _vrijemeOd ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _vrijemeOd = picked);
  }

  Future<void> _birajVrijemeDo() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _vrijemeDo ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) setState(() => _vrijemeDo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // NOVO: vrijednosti za BE "HH:mm:ss"
    final rvOd = _vrijemeOd != null ? _fmtHHmmss(_vrijemeOd!) : null;
    final rvDo = _vrijemeDo != null ? _fmtHHmmss(_vrijemeDo!) : null;

    final saloon = Saloon(
      saloonId: widget.isEdit ? widget.saloon?.saloonId : null, // BITNO za PUT
      nazivSalona: _nazivCtl.text.trim(),
      adresaUlica: _ulicaCtl.text.trim(),
      adresaBroj: _brojCtl.text.trim().isEmpty ? null : _brojCtl.text.trim(),
      grad: _gradCtl.text.trim(),
      postanskiBroj:
      _postanskiCtl.text.trim().isEmpty ? null : _postanskiCtl.text.trim(),
      lokacija:
      _lokacijaCtl.text.trim().isEmpty ? null : _lokacijaCtl.text.trim(),
      brojTelefona: _telefonCtl.text.trim(),
      email: _emailCtl.text.trim(),
      adminIme: _adminImeCtl.text.trim(),
      password: widget.isEdit
          ? ( _passwordCtl.text.trim().isEmpty
          ? widget.saloon?.password ?? ""
          : _passwordCtl.text.trim())
          : _passwordCtl.text.trim(),
      logo: _logoCtl.text.trim().isEmpty ? null : _logoCtl.text.trim(),
      radnoVrijemeOd: rvOd,
      radnoVrijemeDo: rvDo,
    );

    try {
      if (widget.isEdit) {
        await _service.update(saloon);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izmjene spašene')),
        );
        Navigator.of(context).pop(true); // nazad na details
      } else {
        await _service.register(saloon);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salon uspješno registriran')),
        );
        // reset forme
        _formKey.currentState!.reset();
        _nazivCtl.clear();
        _ulicaCtl.clear();
        _brojCtl.clear();
        _gradCtl.clear();
        _postanskiCtl.clear();
        _lokacijaCtl.clear();
        _telefonCtl.clear();
        _emailCtl.clear();
        _radnoCtl.clear();
        _logoCtl.clear();
        _adminImeCtl.clear();
        _passwordCtl.clear();
        setState(() {
          _vrijemeOd = null;
          _vrijemeDo = null;
        });
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.isEdit ? 'Izmijeni salon' : 'Register Saloon')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _nazivCtl, decoration: _dec('Naziv salona'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _ulicaCtl, decoration: _dec('Ulica'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(controller: _brojCtl, decoration: _dec('Broj')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _adminImeCtl, decoration: _dec('Admin ime'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtl,
                decoration: _dec('Password'),
                obscureText: true,
                  validator: (v) {
                    if (!widget.isEdit) {
                      // prilikom registracije obavezno
                      return (v == null || v.trim().isEmpty) ? 'Obavezno polje' : null;
                    }
                    // prilikom editiranja može biti prazno
                    return null;
                  },
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _gradCtl, decoration: _dec('Grad'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _postanskiCtl, decoration: _dec('Poštanski broj')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _lokacijaCtl, decoration: _dec('Lokacija (Google Maps URL)')),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonCtl,
                decoration: _dec('Kontakt telefon'),
                validator: _req,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtl,
                decoration: _dec('Email'),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Obavezno polje';
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v!.trim());
                  return ok ? null : 'Neispravan email';
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // --- Radno vrijeme ---
              const Text('Radno vrijeme', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                decoration: _dec('Radno vrijeme od'),
                controller: TextEditingController(
                  text: _vrijemeOd == null ? '' : _vrijemeOd!.format(context),
                ),
                onTap: _birajVrijemeOd,
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                decoration: _dec('Radno vrijeme do'),
                controller: TextEditingController(
                  text: _vrijemeDo == null ? '' : _vrijemeDo!.format(context),
                ),
                onTap: _birajVrijemeDo,
              ),

              const SizedBox(height: 12),
              TextFormField(controller: _logoCtl, decoration: _dec('Logo URL')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.isEdit ? 'Spasi izmjene' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
