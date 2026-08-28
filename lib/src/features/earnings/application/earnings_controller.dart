import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/earnings_repository.dart';
import '../domain/earnings_models.dart';
import '../domain/fee_calculator.dart';

final feeCalculatorProvider = Provider.family<FeeCalculator, double>(
    (ref, rate) => FeeCalculator(platformFeeRate: rate));
final earningsPeriodProvider =
    NotifierProvider<EarningsPeriodController, EarningsPeriod>(
        EarningsPeriodController.new);

class EarningsPeriodController extends Notifier<EarningsPeriod> {
  @override
  EarningsPeriod build() {
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    return EarningsPeriod.thisMonth;
  }

  void select(EarningsPeriod period) => state = period;
}

final earningsControllerProvider =
    AsyncNotifierProvider.autoDispose<EarningsController, EarningsView>(
        EarningsController.new,
        retry: (_, __) => null);

class EarningsController extends AsyncNotifier<EarningsView> {
  @override
  Future<EarningsView> build() async {
    ref.watch(authControllerProvider
        .select((s) => (s.status, s.user?.id, s.user?.role)));
    ref.watch(localeControllerProvider);
    final period = ref.watch(earningsPeriodProvider);
    final data = await ref.watch(earningsRepositoryProvider).load(period);
    if (!ref.mounted) throw StateError('Earnings request superseded');
    return EarningsView(
        data, ref.watch(feeCalculatorProvider(data.estimateRate)));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
