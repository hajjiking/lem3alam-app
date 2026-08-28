import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/earnings_models.dart';

final earningsRepositoryProvider = Provider((ref) => EarningsRepository(
    ref.watch(apiClientProvider),
    () => ref.read(authControllerProvider),
    () => ref.read(authControllerProvider.notifier).expireSession()));

class EarningsRepository {
  EarningsRepository(this.api, this.auth, this.expire);
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expire;
  int get _owner {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        state.user?.isTasker != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  Future<EarningsLedger> load(EarningsPeriod period) async {
    final owner = _owner;
    Map<String, dynamic>? metadata;
    final records = <String, TransactionRecord>{};
    try {
      for (var page = 1;; page++) {
        if (_owner != owner) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        final result = await api
            .getJson<Map<String, dynamic>>('tasker/earnings', queryParameters: {
          'period': period.apiValue,
          'page': page,
          'per_page': 100,
          if (metadata != null) 'as_of': metadata['as_of'],
        });
        if (_owner != owner) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        if (result['success'] != true ||
            result['data'] is! Map<String, dynamic>) {
          throw const ApiException(message: 'err_unknown');
        }
        final data = result['data'] as Map<String, dynamic>;
        if (data['tasker_id'] != owner ||
            data['period'] != period.apiValue ||
            data['currency'] != 'MAD') {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        metadata ??= data;
        final ledger = data['ledger'] as Map<String, dynamic>;
        if (ledger['current_page'] != page || ledger['data'] is! List) {
          throw const ApiException(message: 'err_unknown');
        }
        for (final json in ledger['data'] as List) {
          final record =
              TransactionRecord.fromJson(json as Map<String, dynamic>);
          records[record.id] = record;
        }
        if (page >= (ledger['last_page'] as num)) break;
      }
      if (records.length !=
          (metadata['ledger'] as Map<String, dynamic>)['total']) {
        throw const ApiException(message: 'err_unknown');
      }
      for (final json in metadata['estimates'] as List) {
        final record = TransactionRecord.fromJson(json as Map<String, dynamic>);
        records[record.id] = record;
      }
      return EarningsLedger.fromJson(metadata, records.values.toList());
    } on ApiException catch (e) {
      if (e.statusCode == 401 && auth().user?.id == owner) await expire();
      rethrow;
    }
  }
}
