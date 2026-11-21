import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tax.dart';

class AppState extends ChangeNotifier {
  double wht = TaxCalc.defaultWht;
  double gst = TaxCalc.defaultGst;
  bool dark = false;
  bool urdu = false;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      wht = p.getDouble('wht') ?? wht;
      gst = p.getDouble('gst') ?? gst;
      dark = p.getBool('dark') ?? dark;
      urdu = p.getBool('urdu') ?? urdu;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble('wht', wht);
      await p.setDouble('gst', gst);
      await p.setBool('dark', dark);
      await p.setBool('urdu', urdu);
    } catch (_) {}
  }

  void update({double? wht, double? gst, bool? dark, bool? urdu}) {
    this.wht = wht ?? this.wht;
    this.gst = gst ?? this.gst;
    this.dark = dark ?? this.dark;
    this.urdu = urdu ?? this.urdu;
    notifyListeners();
    _save();
  }

  void resetRates() => update(wht: TaxCalc.defaultWht, gst: TaxCalc.defaultGst);
}
