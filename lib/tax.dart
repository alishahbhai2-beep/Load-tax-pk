class TaxResult {
  final double amount, balance, totalTax;
  const TaxResult(this.amount, this.balance, this.totalTax);
}

class TaxCalc {
  static const double defaultWht = 15.0; // advance income tax %

  static double r2(double v) => (v * 100).roundToDouble() / 100;

  /// Load amount -> usable balance.
  static TaxResult forward(double amount, double wht) {
    final balance = amount / (1 + wht / 100);
    return TaxResult(r2(amount), r2(balance), r2(amount - balance));
  }

  /// Wanted balance -> load amount to buy.
  static double reverse(double balance, double wht) =>
      r2(balance * (1 + wht / 100));
}
