import 'package:flutter/material.dart';
import 'package:healthsync/models/document.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Document> documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Load documents from the service //
      // documents = await documentService.getDocumentsSortedByDate();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HealthSync"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un document spécifique',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // //
              },
            ),
            TextButton(
              onPressed: () {
                // Add a document //
              },
              child: const Text('Ajouter un document'),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Filtrer par catégorie',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // //
              },
            ),

            // List all documents //
            // Call a service function that will be implemented later //
            const SizedBox(height: 16),
            const Expanded(child: Center(child: Text('Mes documents'))),
          ],
        ),
      ),
    );
  }
}
