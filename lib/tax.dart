class TaxResult {
  final double amount, balance, totalTax, incomeTax, salesTax;
  const TaxResult(this.amount, this.balance, this.totalTax, this.incomeTax, this.salesTax);
}

class TaxCalc {
  static const double defaultWht = 15.0; // advance income tax %
  static const double defaultGst = 19.5; // sales tax %

  static double r2(double v) => (v * 100).roundToDouble() / 100;

  /// Load amount -> usable balance.
  static TaxResult forward(double amount, double wht, double gst) {
    final afterWht = amount / (1 + wht / 100);
    final balance = afterWht / (1 + gst / 100);
    return TaxResult(
      r2(amount),
      r2(balance),
      r2(amount - balance),
      r2(amount - afterWht),
      r2(afterWht - balance),
    );
  }

  /// Wanted balance -> load amount to buy.
  static double reverse(double balance, double wht, double gst) =>
      r2(balance * (1 + wht / 100) * (1 + gst / 100));
}
