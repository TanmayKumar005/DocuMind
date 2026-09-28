class DocumentModel {
  final String id;
  final String name;
  final int chunks;
  final String status;

  DocumentModel({
    required this.id,
    required this.name,
    required this.chunks,
    required this.status,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      chunks: json['chunks'] ?? 0,
      status: json['status'] ?? 'ready',
    );
  }
}
