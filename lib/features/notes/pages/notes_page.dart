import 'package:flutter/material.dart';
import 'package:healthsync/enums/note_category.dart';
import 'package:healthsync/models/note.dart';
import 'package:healthsync/features/notes/pages/note_detail_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  NoteCategory? selectedCategory;

  // Example notes to remove after //
  final List<Note> notes = [
    Note(
      id: '1',
      title: 'Douleur poitrine',
      content: 'Douleur ressentie après le sport.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: NoteCategory.symptome,
      tags: const ['cardio'],
    ),
    Note(
      id: '2',
      title: 'Consultation cardiologue',
      content: 'Le médecin recommande un ECG.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: NoteCategory.consultation,
    ),
  ];

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
            setState(() {
              notes.add(newNote);
            });
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
              child: filteredNotes.isEmpty
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

                            trailing: const Icon(Icons.arrow_forward_ios),

                            onTap: () async {
                              final updatedNote = await Navigator.push<Note>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteDetailPage(note: note),
                                ),
                              );
                              if (updatedNote != null) {
                                setState(() {
                                  final index = notes.indexWhere(
                                    (n) => n.id == updatedNote.id,
                                  );
                                  if (index != -1) {
                                    notes[index] = updatedNote;
                                  }
                                });
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
