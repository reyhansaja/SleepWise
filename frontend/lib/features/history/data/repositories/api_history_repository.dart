import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../auth/data/auth_service.dart';
import '../../domain/entities/sleep_record.dart';
import '../../domain/repositories/history_repository.dart';

class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<SleepRecord>> getRecords({String? token}) async {
    final http.Response res;
    try {
      res = await _client
          .get(
            Uri.parse('$apiBase/predictions?limit=50'),
            headers: {if (token != null) 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw HistoryException('Tidak bisa menghubungi server ($apiBase).\n$e');
    }

    final data = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200) {
      throw HistoryException(
        (data['error'] as String?) ?? 'Gagal memuat riwayat (${res.statusCode}).',
      );
    }

    return [
      for (final row in (data['data'] as List? ?? const []))
        if (row is Map<String, dynamic>) SleepRecord.fromJson(row),
    ];
  }
}

final historyRepositoryProvider =
    Provider<HistoryRepository>((ref) => ApiHistoryRepository());

class HistoryException implements Exception {
  HistoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
