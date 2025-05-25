import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  List<Note> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  final DatabaseService _databaseService = DatabaseService.instance;

  // Load all notes from database
  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _databaseService.getAllNotes();
      _filterNotes();
    } catch (e) {
      _error = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new note
  Future<void> addNote(String title, String content) async {
    try {
      final now = DateTime.now();
      final note = Note(
        title: title.trim(),
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseService.insertNote(note);
      final newNote = note.copyWith(id: id);
      
      _notes.insert(0, newNote);
      _filterNotes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add note: $e';
      notifyListeners();
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note, String title, String content) async {
    try {
      final updatedNote = note.copyWith(
        title: title.trim(),
        content: content.trim(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateNote(updatedNote);
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        // Move updated note to top
        _notes.removeAt(index);
        _notes.insert(0, updatedNote);
        _filterNotes();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update note: $e';
      notifyListeners();
    }
  }

  // Delete a note
  Future<void> deleteNote(int noteId) async {
    try {
      await _databaseService.deleteNote(noteId);
      _notes.removeWhere((note) => note.id == noteId);
      _filterNotes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete note: $e';
      notifyListeners();
    }
  }

  // Search notes
  void searchNotes(String query) {
    _searchQuery = query.trim();
    _filterNotes();
    notifyListeners();
  }

  // Filter notes based on search query
  void _filterNotes() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get note by id
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
