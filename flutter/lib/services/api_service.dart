import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import '../models/chat_response.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Android emulator: 10.0.2.2
  // Physical phone: replace with your computer's LAN IP.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  Future<List<DocumentModel>> getDocuments() async {
    final response = await _dio.get('/documents');
    return (response.data['documents'] as List)
        .map((e) => DocumentModel.fromJson(e))
        .toList();
  }

  Future<DocumentModel> uploadDocument(PlatformFile file) async {
    if (file.bytes == null) {
      throw Exception('Could not read selected PDF.');
    }

    final multipartFile = MultipartFile.fromBytes(
      file.bytes!,
      filename: file.name,
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    final response = await _dio.post(
      '/documents/upload',
      data: formData,
    );

    return DocumentModel.fromJson(response.data);
  }

  Future<ChatResponse> ask(String question) async {
    final response = await _dio.post(
      '/documents/chat',
      data: {'question': question},
    );

    return ChatResponse.fromJson(response.data);
  }
}
