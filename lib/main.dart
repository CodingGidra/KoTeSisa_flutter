import 'package:flutter/material.dart';
import 'screens/register_saloon_screen.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserve haircut in Saloon',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.yellow,
        ),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // mapa dropdown akcija
    final Map<String, VoidCallback> menuActions = {
      'Register Saloon': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterSaloonScreen()),
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
        backgroundColor: Colors.grey,
        title: const Text(
          'Reserve haircut in Saloon',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              menuActions[value]?.call(); // pozivamo funkciju iz mape
            },
            itemBuilder: (BuildContext context) {
              return menuActions.keys
                  .map((item) => PopupMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList();
            },
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter saloon name...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
