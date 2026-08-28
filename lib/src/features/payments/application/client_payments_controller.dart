import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../earnings/domain/earnings_models.dart' show EarningsPeriod;
import '../data/client_payments_repository.dart';
import '../domain/client_payments.dart';

final clientPaymentsPeriodProvider =
    NotifierProvider<ClientPaymentsPeriodController, EarningsPeriod>(
        ClientPaymentsPeriodController.new);

class ClientPaymentsPeriodController extends Notifier<EarningsPeriod> {
  @override
  EarningsPeriod build() {
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    return EarningsPeriod.thisMonth;
  }

  void select(EarningsPeriod period) => state = period;
}

final clientPaymentsControllerProvider =
    FutureProvider.autoDispose<ClientPaymentsView>((ref) {
  ref.watch(authControllerProvider
      .select((s) => (s.status, s.user?.id, s.user?.role)));
  ref.watch(localeControllerProvider);
  final period = ref.watch(clientPaymentsPeriodProvider);
  return ref.watch(clientPaymentsRepositoryProvider).load(period);
}, retry: (_, __) => null);
