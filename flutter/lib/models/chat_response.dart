class SourceModel {
  final String document;
  final int? page;
  final String snippet;

  SourceModel({
    required this.document,
    required this.page,
    required this.snippet,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      document: json['document'] ?? '',
      page: json['page'],
      snippet: json['snippet'] ?? '',
    );
  }
}

class ChatResponse {
  final String answer;
  final List<SourceModel> sources;

  ChatResponse({required this.answer, required this.sources});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] ?? '',
      sources: (json['sources'] as List? ?? [])
          .map((e) => SourceModel.fromJson(e))
          .toList(),
    );
  }
}
