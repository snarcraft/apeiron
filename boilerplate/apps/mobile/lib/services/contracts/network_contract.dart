import 'package:dio/dio.dart';

/// The network surface — one contract, Laravel-shaped payloads:
/// the { data, meta } envelope, Sanctum bearer tokens and the
/// 422 validation error map.
abstract class NetworkContract {
  Future<Response<Map<String, dynamic>>> get(String path, {Map<String, dynamic>? queryParameters});

  Future<Response<Map<String, dynamic>>> create(String path, {Map<String, dynamic>? data});

  Future<Response<Map<String, dynamic>>> update(String path, {Map<String, dynamic>? data});

  Future<Response<Map<String, dynamic>>> submit<T>(String action, {Map<String, dynamic>? data});
}
