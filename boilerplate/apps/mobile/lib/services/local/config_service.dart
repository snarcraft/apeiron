import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';

import '../contracts/config_contract.dart';

/// Reads gitignored JSON config from the asset bundle — the
/// mobile equivalent of the backend's secrets/*.env loading.
@LazySingleton(as: ConfigContract)
class ConfigService implements ConfigContract {
  const ConfigService();

  @override
  Future<Map<String, dynamic>> read(String path) async {
    final content = await rootBundle.loadString('assets/$path.json');

    return jsonDecode(content) as Map<String, dynamic>;
  }
}
