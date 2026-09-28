import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/document.dart';
import '../models/chat_response.dart';
import '../services/api_service.dart';

class ChatPage extends StatefulWidget {
  final DocumentModel document;

  const ChatPage({super.key, required this.document});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final api = ApiService();
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final messages = <_Message>[];
  bool sending = false;

  Future<void> send() async {
    final question = controller.text.trim();
    if (question.isEmpty || sending) return;

    controller.clear();
    setState(() {
      messages.add(_Message(role: 'user', text: question));
      sending = true;
    });
    _scrollDown();

    try {
      final result = await api.ask(question);
      if (!mounted) return;
      setState(() {
        messages.add(_Message(
          role: 'assistant',
          text: result.answer,
          sources: result.sources,
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add(_Message(
          role: 'assistant',
          text: 'I could not reach the AI service. Please try again.',
        ));
      });
    } finally {
      if (mounted) {
        setState(() => sending = false);
        _scrollDown();
      }
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.document.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              'AI Document Assistant',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(document: widget.document)
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    itemCount: messages.length + (sending ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (index == messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Ask about this document...',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: sending ? null : send,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final DocumentModel document;

  const _EmptyChat({required this.document});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 64),
            const SizedBox(height: 18),
            Text(
              'Ask anything about ${document.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text(
              'Answers are generated from the indexed document context.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String role;
  final String text;
  final List<SourceModel> sources;

  _Message({
    required this.role,
    required this.text,
    this.sources = const [],
  });
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser
                ? Text(message.text,
                    style: TextStyle(color: scheme.onPrimary))
                : MarkdownBody(data: message.text),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Sources',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 7),
              ...message.sources.map(
                (source) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: scheme.surface,
                  ),
                  child: Text(
                    '📄 ${source.document}'
                    '${source.page != null ? ' • p.${source.page}' : ''}\n'
                    '${source.snippet}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
