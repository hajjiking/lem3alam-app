import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../../earnings/domain/earnings_models.dart' show EarningsPeriod;
import '../domain/client_payments.dart';

final clientPaymentsRepositoryProvider = Provider((ref) =>
    ClientPaymentsRepository(
        ref.watch(apiClientProvider),
        () => ref.read(authControllerProvider),
        () => ref.read(authControllerProvider.notifier).expireSession()));

class ClientPaymentsRepository {
  ClientPaymentsRepository(this.api, this.auth, this.expire);
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expire;
  int get owner {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        state.user?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  Future<ClientPaymentsView> load(EarningsPeriod period) async {
    final account = owner;
    final records = <int, ClientPayment>{};
    Map<String, dynamic>? metadata;
    try {
      for (var page = 1;; page++) {
        if (owner != account) {
          throw const ApiException(message: 'err_forbidden');
        }
        final result = await api
            .getJson<Map<String, dynamic>>('client/payments', queryParameters: {
          'period': period.apiValue,
          'page': page,
          'per_page': 100,
          if (metadata != null) 'as_of': metadata['as_of'],
        });
        if (owner != account || result['success'] != true) {
          throw const ApiException(message: 'err_forbidden');
        }
        final data = result['data'] as Map<String, dynamic>;
        if (data['client_id'] != account ||
            data['period'] != period.apiValue ||
            data['currency'] != 'MAD') {
          throw const ApiException(message: 'err_forbidden');
        }
        if (metadata != null &&
            (data['as_of'] != metadata['as_of'] ||
                data['start_date'] != metadata['start_date'] ||
                data['end_date'] != metadata['end_date'])) {
          throw const FormatException('Inconsistent payment period');
        }
        metadata ??= data;
        final ledger = data['ledger'] as Map<String, dynamic>;
        if (ledger['current_page'] != page ||
            (ledger['last_page'] as num) < page) {
          throw const FormatException('Invalid page');
        }
        for (final item in ledger['data'] as List) {
          final record = ClientPayment.fromJson(item as Map<String, dynamic>);
          if (record.payerId != account) {
            throw const ApiException(message: 'err_forbidden');
          }
          records[record.id] = record;
        }
        if (page >= (ledger['last_page'] as num)) break;
      }
      if (records.length != metadata['ledger']['total']) {
        throw const FormatException('Incomplete payment ledger');
      }
      return ClientPaymentsView(metadata, records.values.toList());
    } on ApiException catch (e) {
      if (e.statusCode == 401 && auth().user?.id == account) await expire();
      rethrow;
    }
  }
}
