import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tax.dart';

class AppState extends ChangeNotifier {
  double wht = TaxCalc.defaultWht;
  bool dark = false;
  bool urdu = false;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      wht = p.getDouble('wht') ?? wht;
      dark = p.getBool('dark') ?? dark;
      urdu = p.getBool('urdu') ?? urdu;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble('wht', wht);
      await p.setBool('dark', dark);
      await p.setBool('urdu', urdu);
    } catch (_) {}
  }

  void update({double? wht, bool? dark, bool? urdu}) {
    this.wht = wht ?? this.wht;
    this.dark = dark ?? this.dark;
    this.urdu = urdu ?? this.urdu;
    notifyListeners();
    _save();
  }

  void resetRates() => update(wht: TaxCalc.defaultWht);
}
