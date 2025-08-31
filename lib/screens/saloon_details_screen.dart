import 'package:flutter/material.dart';
import '../services/register_saloon_service.dart';
import '../models/saloon.dart';
import 'register_saloon_screen.dart';

class SaloonDetailsScreen extends StatefulWidget {
  final int saloonId;
  final String adminIme;      // početne vrijednosti za instant prikaz
  final String nazivSalona;
  final String? logoUrl;
  final String? radnoVrijeme;

  const SaloonDetailsScreen({
    super.key,
    required this.saloonId,
    required this.adminIme,
    required this.nazivSalona,
    this.logoUrl,
    this.radnoVrijeme,
  });

  @override
  State<SaloonDetailsScreen> createState() => _SaloonDetailsScreenState();
}

class _SaloonDetailsScreenState extends State<SaloonDetailsScreen> {
  final _svc = RegisterSaloonService(baseUrl: 'http://10.0.2.2:5029');

  Saloon? _saloon;        // 👈 držimo CIJELI model
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // inicijalni prikaz iz props-a (da nešto vidimo odmah)
    _saloon = Saloon(
      saloonId: widget.saloonId,
      nazivSalona: widget.nazivSalona,
      adresaUlica: '',
      grad: '',
      brojTelefona: '',
      email: '',
      adminIme: widget.adminIme,
      password: '',
      adresaBroj: null,
      postanskiBroj: null,
      lokacija: widget.logoUrl, // ako želiš striktno, postavi null; ovo je nebitno za prikaz
      radnoVrijeme: widget.radnoVrijeme,
      logo: widget.logoUrl,
    );
    _refreshFromApi(); // opcionalno: odmah sync sa backendom
  }

  Future<void> _refreshFromApi() async {
    setState(() => _loading = true);
    try {
      final fresh = await _svc.fetchById(widget.saloonId);
      if (mounted) setState(() => _saloon = fresh);
    } catch (_) {
      // možeš dodati SnackBar ako želiš
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditAndRefresh() async {
    try {
      final current = await _svc.fetchById(widget.saloonId);
      if (!mounted) return;
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => RegisterSaloonScreen(saloon: current, isEdit: true),
        ),
      );
      if (updated == true && mounted) await _refreshFromApi();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _saloon; // local alias

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36, height: 36,
                child: (s?.logo != null && s!.logo!.isNotEmpty)
                    ? Image.network(s.logo!, fit: BoxFit.cover)
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s?.nazivSalona ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              s?.adminIme ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _openEditAndRefresh,
                    child: const Text('Izmijeni info'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Radno vrijeme',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          (s?.radnoVrijeme != null && s!.radnoVrijeme!.isNotEmpty)
                              ? s.radnoVrijeme!
                              : 'Nije postavljeno',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[900],
                  child: const SizedBox(
                    height: 180,
                    child: Center(
                      child: Text('📅 Placeholder za kalendar',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // crveno dugme
                      foregroundColor: Colors.black, // crna slova
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Navigacija nazad na landing page
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
