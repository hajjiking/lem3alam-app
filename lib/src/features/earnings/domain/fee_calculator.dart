/// All money is calculated in minor units, rounding fees once per transaction.
/// This default is only an estimate; historical payment fees are authoritative.
class FeeCalculator {
  static const defaultEstimateRate = 0.05;
  const FeeCalculator({this.platformFeeRate = defaultEstimateRate});
  final double platformFeeRate;

  static int minorUnits(Object amount) {
    final match =
        RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(amount.toString());
    if (match == null) throw FormatException('Invalid monetary amount', amount);
    return int.parse(match[1]!) * 100 +
        int.parse((match[2] ?? '').padRight(2, '0'));
  }

  FeeAmounts calculate(int grossMinor,
      {int? recordedFeeMinor, int? recordedNetMinor}) {
    if (grossMinor < 0 ||
        !platformFeeRate.isFinite ||
        platformFeeRate < 0 ||
        platformFeeRate > 1) {
      throw ArgumentError('Invalid amount or rate');
    }
    final basisPoints = (platformFeeRate * 10000).round();
    final fee =
        recordedFeeMinor ?? ((grossMinor * basisPoints + 5000) ~/ 10000);
    if (fee < 0 || fee > grossMinor) {
      throw const FormatException('Invalid recorded fee');
    }
    final net = grossMinor - fee;
    if (recordedNetMinor != null && recordedNetMinor != net) {
      throw const FormatException(
          'Recorded gross, fee and net do not reconcile');
    }
    return FeeAmounts(grossMinor, fee, net);
  }

  double platformFee(num grossAmount) =>
      calculate(minorUnits(grossAmount)).fee / 100;
  double netEarnings(num grossAmount) =>
      calculate(minorUnits(grossAmount)).net / 100;
}

class FeeAmounts {
  const FeeAmounts(this.gross, this.fee, this.net);
  final int gross, fee, net;
  FeeAmounts operator +(FeeAmounts other) =>
      FeeAmounts(gross + other.gross, fee + other.fee, net + other.net);
}
