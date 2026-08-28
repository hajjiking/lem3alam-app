import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/fee_calculator.dart';

void main() {
  const calculator = FeeCalculator();
  test('five percent fee and net', () {
    expect(calculator.platformFee(200), 10);
    expect(calculator.netEarnings(200), 190);
    expect(calculator.platformFee(150), 7.5);
    expect(calculator.netEarnings(0), 0);
  });
  test('exact decimal parsing and half-up rounding per transaction', () {
    expect(FeeCalculator.minorUnits('200.01'), 20001);
    expect(calculator.calculate(10).fee, 1);
    expect(calculator.calculate(9).fee, 0);
    expect(calculator.calculate(257900).fee, 12895);
    expect(calculator.calculate(257900).net, 245005);
  });
  test('historical recorded fees take precedence over estimate rate', () {
    final amount = calculator.calculate(20000,
        recordedFeeMinor: 2000, recordedNetMinor: 18000);
    expect(amount.fee, 2000);
    expect(amount.net, 18000);
    expect(const FeeCalculator(platformFeeRate: .1).calculate(20000).fee, 2000);
  });
  test(
      'invalid money, fees, rates and mismatched ledger values fail explicitly',
      () {
    expect(() => FeeCalculator.minorUnits('1.001'), throwsFormatException);
    expect(() => FeeCalculator.minorUnits('-1'), throwsFormatException);
    expect(() => calculator.calculate(-1), throwsArgumentError);
    expect(() => const FeeCalculator(platformFeeRate: 1.1).calculate(100),
        throwsArgumentError);
    expect(() => calculator.calculate(100, recordedFeeMinor: 101),
        throwsFormatException);
    expect(
        () => calculator.calculate(100,
            recordedFeeMinor: 10, recordedNetMinor: 95),
        throwsFormatException);
  });
}
