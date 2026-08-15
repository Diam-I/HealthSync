import 'package:flutter/material.dart';
import 'package:healthsync/enums/note_category.dart';
import 'package:healthsync/models/note.dart';
import 'package:healthsync/features/notes/pages/note_detail_page.dart';
import 'package:healthsync/features/notes/services/note_service.dart';

class NotesPage extends StatefulWidget {
  final NoteService noteService;
  const NotesPage({super.key, required this.noteService});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  NoteCategory? selectedCategory;

  List<Note> notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final allNotes = await widget.noteService.getNotesSortedByDate();
      setState(() {
        notes = allNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Note> get filteredNotes {
    if (selectedCategory == null) return notes;

    return notes.where((note) => note.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HealthSync"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push<Note>(
            context,
            MaterialPageRoute(builder: (context) => const NoteDetailPage()),
          );
          if (newNote != null) {
            await widget.noteService.addNote(newNote);
            await _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mes notes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("Toutes"),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = null;
                    });
                  },
                ),

                ...NoteCategory.values.map((category) {
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text("Erreur : $_errorMessage"))
                  : filteredNotes.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune note",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),

                          child: ListTile(
                            title: Text(note.title),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.category.name),

                                const SizedBox(height: 4),

                                Text(
                                  note.createdAt.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: "Supprimer",
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Supprimer la note ?"),
                                    content: Text(
                                      "Voulez-vous vraiment supprimer \"${note.title}\" ?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Annuler"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Supprimer"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await widget.noteService.deleteNote(note.id);
                                  await _loadNotes();
                                }
                              },
                            ),
                            onTap: () async {
                              final updatedNote = await Navigator.push<Note>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteDetailPage(note: note),
                                ),
                              );

                              if (updatedNote != null) {
                                await widget.noteService.updateNote(
                                  updatedNote,
                                );
                                await _loadNotes();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
