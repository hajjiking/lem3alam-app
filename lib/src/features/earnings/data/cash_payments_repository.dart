import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/fee_calculator.dart';

class CashPayment {
  CashPayment.fromJson(Map<String, dynamic> json)
      : taskId = (json['task_id'] as num).toInt(),
        taskerId = (json['tasker_id'] as num).toInt(),
        title = json['task_title'] as String,
        amount = json['amount'] as String?,
        canConfirm = json['can_confirm'] == true {
    if (json['currency'] != 'MAD' || (canConfirm && amount == null)) {
      throw const FormatException('Invalid cash payment');
    }
    if (amount != null) FeeCalculator.minorUnits(amount!);
  }
  final int taskId, taskerId;
  final String title;
  final String? amount;
  final bool canConfirm;
}

final cashPaymentsRepositoryProvider = Provider((ref) => CashPaymentsRepository(
    ref.watch(apiClientProvider),
    () => ref.read(authControllerProvider),
    () => ref.read(authControllerProvider.notifier).expireSession()));

final cashPaymentsProvider =
    FutureProvider.autoDispose.family<List<CashPayment>, int?>((ref, taskId) {
  final auth = ref.watch(authControllerProvider);
  if (auth.status != AuthStatus.authenticated || auth.user?.isTasker != true) {
    return [];
  }
  return ref.watch(cashPaymentsRepositoryProvider).load(taskId: taskId);
}, retry: (_, __) => null);

class CashPaymentsRepository {
  CashPaymentsRepository(this.api, this.auth, this.expire);
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expire;
  int get owner {
    final identity = auth();
    if (identity.status != AuthStatus.authenticated ||
        identity.user?.isTasker != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return identity.user!.id;
  }

  Future<List<CashPayment>> load({int? taskId}) async {
    final account = owner;
    final result = <int, CashPayment>{};
    try {
      for (var page = 1;; page++) {
        if (owner != account) {
          throw const ApiException(message: 'err_forbidden');
        }
        final response = await api.getJson<Map<String, dynamic>>(
            'tasker/cash-payments',
            queryParameters: {
              'page': page,
              'per_page': 100,
              if (taskId != null) 'task_id': taskId
            });
        if (owner != account || response['success'] != true) {
          throw const ApiException(message: 'err_forbidden');
        }
        final data = response['data'] as Map<String, dynamic>;
        if (data['current_page'] != page) {
          throw const FormatException('Invalid page');
        }
        for (final json in data['data'] as List) {
          final payment = CashPayment.fromJson(json as Map<String, dynamic>);
          if (payment.taskerId != account ||
              (taskId != null && payment.taskId != taskId)) {
            throw const ApiException(message: 'err_forbidden');
          }
          result[payment.taskId] = payment;
        }
        if (page >= (data['last_page'] as num)) break;
      }
      return result.values.toList();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && auth().user?.id == account) await expire();
      rethrow;
    }
  }

  Future<void> confirm(CashPayment payment) async {
    final account = owner;
    if (payment.taskerId != account ||
        !payment.canConfirm ||
        payment.amount == null) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    try {
      final response = await api.postJson<Map<String, dynamic>>(
          'tasks/${payment.taskId}/confirm-cash',
          data: {'amount': payment.amount});
      if (owner != account || response['success'] != true) {
        throw const ApiException(message: 'err_forbidden');
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 && auth().user?.id == account) await expire();
      rethrow;
    }
  }
}
