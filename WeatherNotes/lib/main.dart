import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: '.SF UI Text',
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AppleNotesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppleNotesScreen extends StatefulWidget {
  const AppleNotesScreen({super.key});

  @override
  State<AppleNotesScreen> createState() => _AppleNotesScreenState();
}

class _AppleNotesScreenState extends State<AppleNotesScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  Weather? currentWeather;
  bool isLoadingWeather = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredNotes = notes;
    _searchController.addListener(_filterNotes);
    _loadMexicoCityWeather();
  }

  void _loadMexicoCityWeather() async {
    setState(() {
      isLoadingWeather = true;
    });
    
    try {
      final weather = await _getWeather('Mexico City');
      setState(() {
        currentWeather = weather;
        isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        currentWeather = null;
        isLoadingWeather = false;
      });
    }
  }

  Future<Weather?> _getWeather(String city) async {
    try {
      const apiKey = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');
      
      if (apiKey.isEmpty) {
        throw Exception('API key not provided');
      }
      
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city,MX&appid=$apiKey&units=metric&lang=es'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather(
          cityName: data['name'],
          country: data['sys']['country'],
          temperature: data['main']['temp'].toDouble(),
          description: data['weather'][0]['description'],
          feelsLike: data['main']['feels_like'].toDouble(),
          humidity: data['main']['humidity'],
          windSpeed: data['wind']['speed'].toDouble(),
        );
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Weather error: $e');
      return null;
    }
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
               note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addNote(String title, String content) {
    setState(() {
      notes.insert(0, Note(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.isEmpty ? 'Sin título' : title,
        content: content,
        createdAt: DateTime.now(),
      ));
      _filterNotes();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      final originalIndex = notes.indexWhere((note) => note.id == filteredNotes[index].id);
      if (originalIndex != -1) {
        notes.removeAt(originalIndex);
        _filterNotes();
      }
    });
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // Clima automático para Ciudad de México - Tamaño más grande
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Ciudad de México',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isLoadingWeather)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        SizedBox(height: 16),
                        Text(
                          'Cargando clima...',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    )
                  else if (currentWeather != null) ...[
                    Text(
                      '${currentWeather!.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w100,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentWeather!.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail('Sensación', '${currentWeather!.feelsLike.round()}°'),
                          Container(width: 1, height: 40, color: Colors.white30),
                          _buildWeatherDetail('Humedad', '${currentWeather!.humidity}%'),
                          Container(width: 1, height: 40, color: Colors.white30),
                          _buildWeatherDetail('Viento', '${(currentWeather!.windSpeed * 3.6).round()} km/h'),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.cloud_off,
                      color: Colors.white70,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Clima no disponible',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifica tu conexión a internet',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Sección de notas estilo Apple
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header con búsqueda y botón agregar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E5EA)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Notas',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE5E5EA)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: const InputDecoration(
                                        hintText: 'Buscar en notas...',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.search,
                                    color: Color(0xFF8E8E93),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewNoteScreen(
                                    onSave: _addNote,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF007AFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de notas
                    Expanded(
                      child: filteredNotes.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.note_add,
                                    size: 64,
                                    color: Color(0xFF8E8E93),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay notas aún',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Toca el botón + para crear una',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = filteredNotes[index];
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFF0F0F0)),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    title: Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1E),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (note.content.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            note.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF8E8E93),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(note.createdAt),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFC7C7CC),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFFF3B30),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Eliminar nota'),
                                              content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteNote(index);
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Nota eliminada')),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Eliminar',
                                                    style: TextStyle(color: Color(0xFFFF3B30)),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewNoteScreen(
                                            onSave: (title, content) {
                                              setState(() {
                                                final originalIndex = notes.indexWhere(
                                                  (n) => n.id == note.id,
                                                );
                                                if (originalIndex != -1) {
                                                  notes[originalIndex] = Note(
                                                    id: note.id,
                                                    title: title.isEmpty ? 'Sin título' : title,
                                                    content: content,
                                                    createdAt: note.createdAt,
                                                  );
                                                  _filterNotes();
                                                }
                                              });
                                            },
                                            initialTitle: note.title,
                                            initialContent: note.content,
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hours = difference.inHours;
      if (hours == 0) {
        final minutes = difference.inMinutes;
        return minutes < 1 ? 'Ahora' : '${minutes} min';
      }
      return '${hours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Nueva pantalla para crear notas
class NewNoteScreen extends StatefulWidget {
  final Function(String, String) onSave;
  final String? initialTitle;
  final String? initialContent;
  
  const NewNoteScreen({
    super.key, 
    required this.onSave,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF007AFF)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty || _contentController.text.trim().isNotEmpty) {
                widget.onSave(_titleController.text.trim(), _contentController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota guardada')),
                );
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Título',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF8E8E93)),
              ),
              autofocus: true,
            ),
            const Divider(color: Color(0xFFE5E5EA)),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu nota...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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

class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });
}