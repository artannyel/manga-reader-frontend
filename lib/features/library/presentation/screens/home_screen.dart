import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock manga data for testing routing and layout
    final mockMangas = [
      {'id': 'manga-1', 'title': 'Chainsaw Man', 'author': 'Tatsuki Fujimoto'},
      {'id': 'manga-2', 'title': 'One Piece', 'author': 'Eiichiro Oda'},
      {'id': 'manga-3', 'title': 'Jujutsu Kaisen', 'author': 'Gege Akutami'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockMangas.length,
        itemBuilder: (context, index) {
          final manga = mockMangas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.book, color: Colors.white),
              ),
              title: Text(
                manga['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(manga['author']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/manga/${manga['id']}');
              },
            ),
          );
        },
      ),
    );
  }
}
