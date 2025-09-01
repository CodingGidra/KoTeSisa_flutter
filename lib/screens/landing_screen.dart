import 'dart:async';
import 'package:flutter/material.dart';

import 'register_saloon_screen.dart';
import 'sign_in_screen.dart';
import 'saloon_details_screen.dart';

import '../models/saloon.dart';
import '../services/register_saloon_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _queryCtl = TextEditingController();
  final _svc = RegisterSaloonService(baseUrl: 'http://10.0.2.2:5029');

  Timer? _debounce;
  bool _loading = false;
  List<Saloon> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final q = v.trim();
      if (q.length < 3) {
        if (mounted) setState(() => _results = []);
        return;
      }
      setState(() => _loading = true);
      try {
        final res = await _svc.search(q);
        if (mounted) setState(() => _results = res);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška u pretrazi: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, VoidCallback> menuActions = {
      'Register Saloon': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterSaloonScreen()),
        );
      },
      'Sign In': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      },
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 6,
        title: const Text(
          '💈💈 Ko te SISA 💈💈 ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => menuActions[value]?.call(),
            itemBuilder: (BuildContext context) {
              return menuActions.keys
                  .map(
                    (item) => PopupMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
                  .toList();
            },
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/landingPage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Search for Saloon',
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _queryCtl,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter saloon name...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              if (_loading) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: _results.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final s = _results[i];
                    return Card(
                      color: Colors.black.withOpacity(0.65),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: (s.logo != null && s.logo!.isNotEmpty)
                                ? Image.network(s.logo!, fit: BoxFit.cover)
                                : Container(color: Colors.grey[800]),
                          ),
                        ),
                        title: Text(
                          s.nazivSalona,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          [
                            s.grad,
                            if (s.adresaUlica.isNotEmpty) s.adresaUlica,
                            if (s.adresaBroj != null &&
                                s.adresaBroj!.isNotEmpty)
                              s.adresaBroj!,
                          ].where((e) => e != null && e.toString().isNotEmpty).join(' • '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SaloonDetailsScreen(
                                saloonId: s.saloonId ?? 0,
                                adminIme: s.adminIme,
                                nazivSalona: s.nazivSalona,
                                logoUrl: s.logo,
                                radnoVrijeme: "${s!.radnoVrijemeOd!.substring(0, 5)} - ${s.radnoVrijemeDo!.substring(0, 5)}",
                                isAdmin: false,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
