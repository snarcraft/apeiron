import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/application.dart';

/// Fetches the server-driven application document — the single
/// source of identity for the whole app.
@lazySingleton
class ApplicationFacade {
  const ApplicationFacade();

  Future<Application> fetch(Dio client) async {
    try {
      final response = await client.get<Map<String, dynamic>>('/');

      final envelope = Envelope.fromJson(response.data ?? {});

      return Application.fromJson(envelope.data);
    } on DioException catch (error) {
      throw Exception('Application document unavailable: ${error.message}');
    }
  }
}

class Envelope {
  const Envelope({required this.data});

  final Map<String, dynamic> data;

  factory Envelope.fromJson(Map<String, dynamic> json) =>
      Envelope(data: json['data'] as Map<String, dynamic>? ?? {});
}
