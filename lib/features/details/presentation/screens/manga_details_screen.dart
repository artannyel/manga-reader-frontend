import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MangaDetailsScreen extends StatelessWidget {
  final String mangaId;

  const MangaDetailsScreen({
    super.key,
    required this.mangaId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock chapters for this manga
    final mockChapters = [
      {'id': 'chapter-1', 'title': 'Capítulo 1: O Começo'},
      {'id': 'chapter-2', 'title': 'Capítulo 2: Novo Encontro'},
      {'id': 'chapter-3', 'title': 'Capítulo 3: O Desafio'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Mangá'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.book, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mangá ID: $mangaId',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Autor: Autor do Mangá',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Status: Em lançamento',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sinopse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta é uma sinopse de exemplo para o mangá selecionado. O sync do MangaDex trará as informações reais na fase seguinte.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Capítulos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockChapters.length,
              itemBuilder: (context, index) {
                final chapter = mockChapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(chapter['title']!),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      context.push('/manga/$mangaId/chapter/${chapter['id']}');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
