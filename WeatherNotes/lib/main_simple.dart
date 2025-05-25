import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NotesWeatherApp());
}

class NotesWeatherApp extends StatelessWidget {
  const NotesWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes & Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Note> notes = [];
  String? weatherData;
  bool isLoadingWeather = false;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSampleNotes();
  }

  void _loadSampleNotes() {
    notes = [
      Note(
        id: 1,
        title: "Bienvenido a Notes & Weather",
        content: "Esta es tu primera nota. Puedes crear más notas usando el botón +",
        createdAt: DateTime.now(),
      ),
      Note(
        id: 2,
        title: "Funciones de la app",
        content: "• Crear y ver notas\n• Consultar el clima por ciudad\n• Interfaz simple y fácil de usar",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  Future<void> _getWeather(String city) async {
    if (city.trim().isEmpty) return;
    
    setState(() {
      isLoadingWeather = true;
    });

    try {
      const apiKey = '6d834949e6247ad48ea249f818b9a0cc';
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = '''
Clima en ${data['name']}:
🌡️ Temperatura: ${data['main']['temp'].round()}°C
🌤️ Descripción: ${data['weather'][0]['description']}
💧 Humedad: ${data['main']['humidity']}%
💨 Viento: ${data['wind']['speed']} m/s
''';
        });
      } else {
        setState(() {
          weatherData = 'Error: Ciudad no encontrada';
        });
      }
    } catch (e) {
      setState(() {
        weatherData = 'Error al consultar el clima. Verifica tu conexión.';
      });
    } finally {
      setState(() {
        isLoadingWeather = false;
      });
    }
  }

  void _addNote() {
    if (_titleController.text.trim().isEmpty && _noteController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      notes.insert(0, Note(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim().isEmpty ? 'Sin título' : _titleController.text.trim(),
        content: _noteController.text.trim(),
        createdAt: DateTime.now(),
      ));
      _titleController.clear();
      _noteController.clear();
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota guardada')),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Weather'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.note), text: 'Notas'),
            Tab(icon: Icon(Icons.wb_sunny), text: 'Clima'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesTab(),
          _buildWeatherTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddNoteDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNotesTab() {
    return notes.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay notas aún'),
                Text('Toca el botón + para crear una'),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(note.createdAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        notes.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nota eliminada')),
                      );
                    },
                  ),
                ),
              );
            },
          );
  }

  Widget _buildWeatherTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Consultar Clima',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la ciudad',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          onSubmitted: (value) => _getWeather(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoadingWeather 
                            ? null 
                            : () => _getWeather(_cityController.text),
                        child: isLoadingWeather
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (weatherData != null)
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        weatherData!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Escribe el nombre de una ciudad'),
                      Text('y toca buscar para ver el clima'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} días atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Ahora';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}

class Note {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
}