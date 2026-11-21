import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'l10n.dart';
import 'tax.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(App(state: state));
}

ThemeData _theme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B8F5B), brightness: b),
    );

class App extends StatelessWidget {
  final AppState state;
  const App({super.key, required this.state});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: state,
        builder: (_, __) => MaterialApp(
          title: 'Load Tax Calculator Pakistan',
          debugShowCheckedModeBanner: false,
          themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          builder: (_, child) => Directionality(
            textDirection: state.urdu ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
          home: Shell(state: state),
        ),
      );
}

class Shell extends StatefulWidget {
  final AppState state;
  const Shell({super.key, required this.state});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final u = widget.state.urdu;
    final pages = [
      CalcPage(state: widget.state),
      ReversePage(state: widget.state),
      SettingsPage(state: widget.state),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(tr(u, 'title')), centerTitle: true),
      body: SafeArea(child: IndexedStack(index: _i, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.calculate_outlined), label: tr(u, 'tabCalc')),
          NavigationDestination(icon: const Icon(Icons.swap_vert), label: tr(u, 'tabReverse')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: tr(u, 'tabSettings')),
        ],
      ),
    );
  }
}

// ---------- shared widgets ----------

final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      );
}

class Disclaimer extends StatelessWidget {
  final bool urdu;
  const Disclaimer(this.urdu, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(tr(urdu, 'disclaimer'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      );
}

String rs(double v) => 'Rs ${v.toStringAsFixed(2)}';

double? parseAmount(String s) {
  final v = double.tryParse(s.trim());
  return (v == null || v <= 0) ? null : v;
}

// ---------- Calculator ----------

const networks = ['Jazz', 'Zong', 'Ufone', 'Telenor'];
const quick = [50, 100, 200, 500, 1000];

class CalcPage extends StatefulWidget {
  final AppState state;
  const CalcPage({super.key, required this.state});
  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  final _c = TextEditingController();
  String _network = networks.first;
  String? _error;
  TaxResult? _res;

  void _calculate() {
    final u = widget.state.urdu;
    if (_c.text.trim().isEmpty) {
      setState(() { _error = tr(u, 'errEmpty'); _res = null; });
      return;
    }
    final v = parseAmount(_c.text);
    if (v == null) {
      setState(() { _error = tr(u, 'errInvalid'); _res = null; });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _res = TaxCalc.forward(v, widget.state.wht);
    });
  }

  void _reset() => setState(() { _c.clear(); _error = null; _res = null; });

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final u = s.urdu;
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr(u, 'subtitle'), style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final n in networks)
          ChoiceChip(label: Text(n), selected: _network == n, onSelected: (_) => setState(() => _network = n)),
      ]),
      const SizedBox(height: 16),
      TextField(
        controller: _c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_amountFormatter],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: tr(u, 'enter'),
          errorText: _error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onSubmitted: (_) => _calculate(),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final q in quick)
          ActionChip(label: Text('$q'), onPressed: () { _c.text = '$q'; _calculate(); }),
      ]),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _calculate,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: Text(tr(u, 'calc')),
      ),
      TextButton(onPressed: _reset, child: Text(tr(u, 'reset'))),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: _res == null
            ? const SizedBox(width: double.infinity)
            : Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$_network · ${tr(u, 'balance')}', style: Theme.of(context).textTheme.labelLarge),
                  Text(rs(_res!.balance),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: cs.primary)),
                  const Divider(height: 28),
                  _row(context, '${tr(u, 'tax')} (${s.wht}%)', rs(_res!.totalTax), bold: true),
                  _row(context, tr(u, 'load'), rs(_res!.amount)),
                ]),
              ),
      ),
      Disclaimer(u),
    ]);
  }

  Widget _row(BuildContext context, String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(l)),
          Text(v, style: TextStyle(fontSize: bold ? 20 : 16, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ]),
      );
}

// ---------- Reverse calculator ----------

class ReversePage extends StatefulWidget {
  final AppState state;
  const ReversePage({super.key, required this.state});
  @override
  State<ReversePage> createState() => _ReversePageState();
}

class _ReversePageState extends State<ReversePage> {
  final _c = TextEditingController();
  String? _error;
  double? _load;

  void _go() {
    final u = widget.state.urdu;
    if (_c.text.trim().isEmpty) {
      setState(() { _error = tr(u, 'errEmpty'); _load = null; });
      return;
    }
    final v = parseAmount(_c.text);
    if (v == null) {
      setState(() { _error = tr(u, 'errInvalid'); _load = null; });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _error = null; _load = TaxCalc.reverse(v, widget.state.wht); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final u = widget.state.urdu;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr(u, 'reverseTitle'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      TextField(
        controller: _c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_amountFormatter],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: tr(u, 'wantBalance'),
          errorText: _error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onSubmitted: (_) => _go(),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _go,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: Text(tr(u, 'reverseBtn')),
      ),
      TextButton(onPressed: () => setState(() { _c.clear(); _error = null; _load = null; }), child: Text(tr(u, 'reset'))),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: _load == null
            ? const SizedBox(width: double.infinity)
            : Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(u, 'buy')),
                  Text(rs(_load!),
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ]),
              ),
      ),
      Disclaimer(u),
    ]);
  }
}

// ---------- Settings ----------

class SettingsPage extends StatefulWidget {
  final AppState state;
  const SettingsPage({super.key, required this.state});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _w = TextEditingController(text: '${widget.state.wht}');

  @override
  void dispose() { _w.dispose(); super.dispose(); }

  double? _rate(String s) {
    final v = double.tryParse(s.trim());
    return (v == null || v < 0 || v > 100) ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final u = s.urdu;
    InputDecoration dec(String k) => InputDecoration(
        labelText: tr(u, k), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr(u, 'ratesNote'), style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 16),
      TextField(
        controller: _w,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: dec('wht'),
        onChanged: (t) { final v = _rate(t); if (v != null) s.update(wht: v); },
      ),
      TextButton(
        onPressed: () {
          s.resetRates();
          _w.text = '${s.wht}';
        },
        child: Text(tr(u, 'resetRates')),
      ),
      SwitchListTile(title: Text(tr(u, 'dark')), value: s.dark, onChanged: (v) => s.update(dark: v)),
      SwitchListTile(title: Text(tr(u, 'lang')), value: s.urdu, onChanged: (v) => s.update(urdu: v)),
      Disclaimer(u),
    ]);
  }
}
