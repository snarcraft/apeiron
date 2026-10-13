import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../contracts/network_contract.dart';

@LazySingleton(as: NetworkContract)
class NetworkService implements NetworkContract {
  const NetworkService(@Named('sanctum') this._client);

  final Dio _client;

  @override
  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _client.get<Map<String, dynamic>>(path, queryParameters: queryParameters);

  @override
  Future<Response<Map<String, dynamic>>> create(
    String path, {
    Map<String, dynamic>? data,
  }) =>
      _client.post<Map<String, dynamic>>(path, data: data);

  @override
  Future<Response<Map<String, dynamic>>> update(
    String path, {
    Map<String, dynamic>? data,
  }) =>
      _client.patch<Map<String, dynamic>>(path, data: data);

  @override
  Future<Response<Map<String, dynamic>>> submit<T>(
    String action, {
    Map<String, dynamic>? data,
  }) =>
      _client.post<Map<String, dynamic>>(action, data: data);
}
