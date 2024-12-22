import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon y Gatos',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorador API'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PokemonSearchScreen()),
                );
              },
              child: const Text('Buscar Pokémon',
                  style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CatFactsScreen()),
                );
              },
              child: const Text('Datos de Gatos', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonSearchScreen extends StatefulWidget {
  const PokemonSearchScreen({super.key});

  @override
  _PokemonSearchScreenState createState() => _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends State<PokemonSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  List<Map<String, dynamic>> _favorites = [];

  Future<void> fetchPokemon(String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _pokemonData = {
            'name': data['name'],
            'image': data['sprites']['front_default'],
            'height': data['height'],
            'weight': data['weight'],
            'types': (data['types'] as List)
                .map((type) => type['type']['name'])
                .toList(),
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _pokemonData = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pokémon no encontrado')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void addToFavorites(Map<String, dynamic> pokemon) {
    setState(() {
      if (!_favorites.any((fav) => fav['name'] == pokemon['name'])) {
        _favorites.add(pokemon);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Añadido a favoritos: ${pokemon['name']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pokemon['name']} ya está en favoritos')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(favorites: _favorites),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => fetchPokemon(_controller.text.toLowerCase()),
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : _pokemonData != null
                    ? Column(
                        children: [
                          if (_pokemonData!['image'] != null)
                            Image.network(_pokemonData!['image']),
                          const SizedBox(height: 8),
                          Text('Nombre: ${_pokemonData!['name']}',
                              style: const TextStyle(fontSize: 18)),
                          Text('Altura: ${_pokemonData!['height']}'),
                          Text('Peso: ${_pokemonData!['weight']}'),
                          Text('Tipos: ${_pokemonData!['types'].join(', ')}'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => addToFavorites(_pokemonData!),
                            icon: const Icon(Icons.favorite),
                            label: const Text('Agregar a Favoritos'),
                          ),
                        ],
                      )
                    : const Text('Introduce un nombre para buscar'),
          ],
        ),
      ),
    );
  }
}

class CatFactsScreen extends StatefulWidget {
  const CatFactsScreen({super.key});

  @override
  _CatFactsScreenState createState() => _CatFactsScreenState();
}

class _CatFactsScreenState extends State<CatFactsScreen> {
  String? _catFact;
  String? _catImageUrl;
  bool _isLoading = false;
  final List<String> _favorites = [];

  Future<void> fetchCatFactAndImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch Cat Fact
      final factUrl = Uri.parse('https://catfact.ninja/fact');
      final factResponse = await http.get(factUrl);

      // Fetch Cat Image
      final imageUrl = Uri.parse('https://api.thecatapi.com/v1/images/search');
      final imageResponse = await http.get(imageUrl);

      if (factResponse.statusCode == 200 && imageResponse.statusCode == 200) {
        final factData = json.decode(factResponse.body);
        final imageData = json.decode(imageResponse.body);

        setState(() {
          _catFact = factData['fact'];
          _catImageUrl = imageData[0]['url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _catFact = 'No se pudo obtener el dato.';
          _catImageUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _catFact = 'Error al cargar datos.';
        _catImageUrl = null;
      });
      print('Error: $e');
    }
  }

  void addToFavorites(String fact) {
    setState(() {
      if (!_favorites.contains(fact)) {
        _favorites.add(fact);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dato añadido a favoritos.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos e Imágenes de Gatos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      if (_catImageUrl != null)
                        Image.network(
                          _catImageUrl!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 16),
                      if (_catFact != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _catFact!,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => addToFavorites(_catFact ?? ''),
                        icon: const Icon(Icons.favorite),
                        label: const Text('Agregar a Favoritos'),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCatFactAndImage,
              child: const Text('Obtener Dato e Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<dynamic> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('No hay favoritos aún.'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  title: Text(item['name'] ?? item),
                  subtitle: Text(item is Map ? 'Pokémon' : 'Dato de Gato'),
                  trailing: const Icon(Icons.favorite, color: Colors.red),
                );
              },
            ),
    );
  }
}
