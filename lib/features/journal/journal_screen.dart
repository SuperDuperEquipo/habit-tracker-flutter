import 'package:flutter/material.dart';
import 'journal_dao.dart';
import 'journal_note.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await JournalDao.instance.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  // Mostrar formulario validado para crear nota
  void _showAddNoteModal() {
    final formKey = GlobalKey<FormState>();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nueva nota del diario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '¿Cómo estuvo tu día?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La nota no puede estar vacía';
                  }
                  if (value.trim().length < 3) {
                    return 'Escribe al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final today = DateTime.now().toIso8601String().split(
                      'T',
                    )[0];
                    final newNote = JournalNote(
                      date: today,
                      content: contentController.text.trim(),
                    );
                    await JournalDao.instance.insertNote(newNote);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadNotes();
                  }
                },
                child: const Text('Guardar Nota'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    await JournalDao.instance.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Diario de Hábitos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('No hay notas registradas aún.'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(note.content),
                    subtitle: Text(
                      note.date,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
