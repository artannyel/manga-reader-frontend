import 'package:flutter/material.dart';

class ChapterReaderScreen extends StatelessWidget {
  final String mangaId;
  final String chapterId;

  const ChapterReaderScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capítulo: $chapterId'),
      ),
      body: PageView.builder(
        itemCount: 5, // Mock pages
        itemBuilder: (context, index) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 450,
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Text(
                      'Página ${index + 1}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mangá ID: $mangaId | Capítulo: $chapterId',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deslize para o lado • ${index + 1}/5',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
