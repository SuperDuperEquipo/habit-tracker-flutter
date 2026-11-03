class JournalNote {
  final int? id;
  final String date; // Formato YYYY-MM-DD
  final String content;

  JournalNote({this.id, required this.date, required this.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'content': content};
  }

  factory JournalNote.fromMap(Map<String, dynamic> map) {
    return JournalNote(
      id: map['id'] as int?,
      date: map['date'] as String,
      content: map['content'] as String,
    );
  }
}
