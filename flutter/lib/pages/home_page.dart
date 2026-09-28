import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  List<DocumentModel> documents = [];
  bool loading = true;
  bool uploading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      final result = await api.getDocuments();
      if (!mounted) return;
      setState(() {
        documents = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not connect to the backend.';
      });
    }
  }

  Future<void> upload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => uploading = true);

    try {
      await api.uploadDocument(result.files.single);
      await loadDocuments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document indexed successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDocuments,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DocuMind',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 5),
                      Text(
                        'Your AI research workspace',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primaryContainer,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ask your documents',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Upload a PDF and use semantic search to get grounded answers.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.auto_awesome,
                                size: 44, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Documents',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          Text('${documents.length} files'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48),
                        const SizedBox(height: 12),
                        Text(error!),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: loadDocuments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (documents.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No documents yet. Upload your first PDF.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(22),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = documents[index];
                        return _DocumentCard(
                          document: doc,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(document: doc),
                            ),
                          ),
                        );
                      },
                      childCount: documents.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisExtent: 190,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploading ? null : upload,
        icon: uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_file),
        label: Text(uploading ? 'Indexing...' : 'Upload PDF'),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.picture_as_pdf,
                  size: 40, color: theme.colorScheme.primary),
              const Spacer(),
              Text(
                document.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 7),
              Text('${document.chunks} indexed chunks'),
              const SizedBox(height: 7),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Ready'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
