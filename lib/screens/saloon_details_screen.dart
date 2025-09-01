import 'package:flutter/material.dart';
import '../services/register_saloon_service.dart';
import '../models/saloon.dart';
import 'register_saloon_screen.dart';
import 'submit_terming_screen.dart';

class SaloonDetailsScreen extends StatefulWidget {
  final int saloonId;
  final String adminIme;
  final String nazivSalona;
  final String? logoUrl;
  final String? radnoVrijeme;
  final bool isAdmin;

  const SaloonDetailsScreen({
    super.key,
    required this.saloonId,
    required this.adminIme,
    required this.nazivSalona,
    this.logoUrl,
    this.radnoVrijeme,
    this.isAdmin = false,
  });

  @override
  State<SaloonDetailsScreen> createState() => _SaloonDetailsScreenState();
}

class _SaloonDetailsScreenState extends State<SaloonDetailsScreen> {
  final _svc = RegisterSaloonService(baseUrl: 'http://10.0.2.2:5029');

  Saloon? _saloon;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // inicijalno popunimo osnovne podatke za odmah prikaz
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
      lokacija: null,
      logo: widget.logoUrl,
    );
    _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    setState(() => _loading = true);
    try {
      final fresh = await _svc.fetchById(widget.saloonId);
      if (mounted) setState(() => _saloon = fresh);
    } catch (_) {
      // po želji: SnackBar
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
    final s = _saloon;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 36,
                height: 36,
                child: (s?.logo != null && s!.logo!.isNotEmpty)
                    ? Image.network(s.logo!, fit: BoxFit.cover)
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s?.nazivSalona ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
              Text(
                s!.adminIme,
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
                if (widget.isAdmin)
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
                        const Text(
                          'Radno vrijeme',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (s?.radnoVrijemeOd != null &&
                              s!.radnoVrijemeDo!.isNotEmpty)
                              ? "${s!.radnoVrijemeOd!.substring(0, 5)} - ${s.radnoVrijemeDo!.substring(0, 5)}"
                              : 'Nije postavljeno',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rezervacija termina (vidljivo svima)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_today, size: 20),
                    label: const Text(
                      'Rezerviši termin',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubmitTerminScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                if (widget.isAdmin) // ✅ admin-only dugmad
                  Row(
                    children: [
                      // Delete Saloon
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.yellow,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.yellow,
                                width: 1,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: const Text(
                                  'Obrisati salon?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Ova radnja je trajna i ne može se poništiti.',
                                  style:
                                  TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ??
                                false;

                            if (!confirmed) return;

                            try {
                              await _svc.deleteById(widget.saloonId);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Salon uspješno obrisan'),
                                ),
                              );
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Greška pri brisanju: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Delete saloon',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Logout
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.black,
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.white.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
