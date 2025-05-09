import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gemini_keys.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(StockCalcApp());
}

class StockCalcApp extends StatelessWidget {
  const StockCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.orange,
          secondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.roboto(color: Colors.white),
          bodyMedium: GoogleFonts.roboto(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          labelStyle: GoogleFonts.roboto(color: Colors.orange),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
        switch (settings.name) {
          case '/home':
            builder = (_) => const HomePage();
            break;
          case '/about':
            builder = (_) => const AboutPage();
            break;
          case '/stockName':
            builder = (_) => const StockNamePage();
            break;
          case '/investment':
            builder = (_) => InvestmentPage(
                  stockName: args!['stockName'],
                  stockFullName: args['stockFullName'],
                  averageReturn: args['averageReturn'],
                  monthlyReturn: args['monthlyReturn'],
                  stockPrice: args['stockPrice'],
                );
            break;
          case '/history':
            builder = (_) => const HistoryPage();
            break;
          default:
            builder = (_) => const HomePage(); // Fallback seguro
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'lib/images/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24),
            Text('StockCalc',
                style: GoogleFonts.montserrat(
                    color: Colors.orange,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }
}

class HeaderFooterScaffold extends StatelessWidget {
  final Widget child;
  final bool showBack;
  const HeaderFooterScaffold({required this.child, this.showBack = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0xFF23272A),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                color: Colors.transparent,
                child: Row(
                  children: [
                    if (showBack) ...[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.orange),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      SizedBox(width: 0),
                    ],
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      child: Text(
                        'StockCalc',
                        style: GoogleFonts.montserrat(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Desenvolvido com ',
                      style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.favorite, color: Colors.red, size: 16),
                        ),
                        TextSpan(
                          text: ' por Pedro Lazzaroni',
                          style: GoogleFonts.roboto(color: Colors.white70),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<bool> _hasHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];
    return history.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderFooterScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'StockCalc',
              style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'lib/images/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/stockName');
                },
                child: Text('Iniciar', style: GoogleFonts.montserrat(fontSize: 22)),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/about');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange,
                  textStyle: GoogleFonts.montserrat(fontSize: 22),
                ),
                child: Text('Sobre', style: GoogleFonts.montserrat(fontSize: 22)),
              ),
            ),
            SizedBox(height: 24),
            FutureBuilder<bool>(
              future: _hasHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink();
                }
                if (snapshot.data == true) {
                  return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/history');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange),
                        foregroundColor: Colors.orange,
                        textStyle: GoogleFonts.montserrat(fontSize: 22),
                      ),
                      child: Text('Histórico', style: GoogleFonts.montserrat(fontSize: 22)),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderFooterScaffold(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              'Sobre o StockCalc 🚀',
              style: GoogleFonts.montserrat(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Text(
              'O StockCalc é seu copiloto para simular investimentos em ações de qualquer país, de forma simples, visual e inteligente!\n\nFuncionalidades principais:',
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• 🔎 Busca inteligente de ações por código (ex: PETR4, AAPL, TSLA)', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• 💹 Simulação de investimento com aportes e tempo customizáveis', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• 📈 Gráfico de evolução do seu investimento', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• 📊 Compare diferentes ações e cenários', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• 🕓 Histórico dos últimos cálculos realizados', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• 🔗 Compartilhe resultados facilmente', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
                Text('• ⚠️ Aviso: os dados vêm da API Gemini 2.0 Flash (Google) e podem não ser precisos (modelo treinado até dez/2023)', style: GoogleFonts.roboto(color: Colors.orange, fontSize: 15)),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Redes sociais',
              style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                  icon: SvgPicture.string(
                    '''
                    <svg width="32" height="32" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path fill="#fff" d="M12 0C5.37 0 0 5.37 0 12a12 12 0 0 0 8.21 11.44c.6.11.82-.26.82-.58v-2.04c-3.34.73-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.75.08-.74.08-.74 1.2.08 1.83 1.23 1.83 1.23 1.07 1.82 2.81 1.29 3.5.98.11-.78.42-1.29.76-1.59-2.66-.3-5.46-1.33-5.46-5.9 0-1.3.47-2.36 1.23-3.19-.12-.3-.53-1.52.12-3.17 0 0 1-.32 3.3 1.23a11.5 11.5 0 0 1 6 0c2.3-1.55 3.3-1.23 3.3-1.23.65 1.65.24 2.87.12 3.17.76.83 1.23 1.89 1.23 3.19 0 4.58-2.8 5.6-5.47 5.9.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.82.58A12 12 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
                      <path fill="#f4841f" d="M12 0C5.37 0 0 5.37 0 12a12 12 0 0 0 8.21 11.44c.6.11.82-.26.82-.58v-2.04c-3.34.73-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.75.08-.74.08-.74 1.2.08 1.83 1.23 1.83 1.23 1.07 1.82 2.81 1.29 3.5.98.11-.78.42-1.29.76-1.59-2.66-.3-5.46-1.33-5.46-5.9 0-1.3.47-2.36 1.23-3.19-.12-.3-.53-1.52.12-3.17 0 0 1-.32 3.3 1.23a11.5 11.5 0 0 1 6 0c2.3-1.55 3.3-1.23 3.3-1.23.65 1.65.24 2.87.12 3.17.76.83 1.23 1.89 1.23 3.19 0 4.58-2.8 5.6-5.47 5.9.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.82.58A12 12 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
                    </svg>
                    ''',
                  ),
                  onPressed: () => launchUrl(Uri.parse('https://github.com/pedrolazzaroni')),
                  tooltip: 'GitHub',
                  ),
                  SizedBox(width: 18),
                  IconButton(
                    icon: SvgPicture.string(
                      '''
                      <svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M7.75 2h8.5A5.75 5.75 0 0 1 22 7.75v8.5A5.75 5.75 0 0 1 16.25 22h-8.5A5.75 5.75 0 0 1 2 16.25v-8.5A5.75 5.75 0 0 1 7.75 2zm0 1.5A4.25 4.25 0 0 0 3.5 7.75v8.5A4.25 4.25 0 0 0 7.75 20.5h8.5A4.25 4.25 0 0 0 20.5 16.25v-8.5A4.25 4.25 0 0 0 16.25 3.5h-8.5zm4.25 3.25a5.25 5.25 0 1 1 0 10.5a5.25 5.25 0 0 1 0-10.5zm0 1.5a3.75 3.75 0 1 0 0 7.5a3.75 3.75 0 0 0 0-7.5zm6.25.75a1.25 1.25 0 1 1-2.5 0a1.25 1.25 0 0 1 2.5 0z" fill="#fff"/>
                        <path d="M12 6.25a5.75 5.75 0 1 1 0 11.5a5.75 5.75 0 0 1 0-11.5zm0 1.5a4.25 4.25 0 1 0 0 8.5a4.25 4.25 0 0 0 0-8.5zm6.25.75a1.25 1.25 0 1 1-2.5 0a1.25 1.25 0 0 1 2.5 0z" fill="#f4841f"/>
                      </svg>
                      ''',
                    ),
                    onPressed: () => launchUrl(Uri.parse('https://instagram.com/pedro_lazzaroni')),
                    tooltip: 'Instagram',
                  ),
                  SizedBox(width: 18),
                  IconButton(
                    icon: SvgPicture.string(
                      '''
                      <svg width="32" height="32" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M4.98 3.5C4.98 4.6 4.1 5.5 3 5.5S1 4.6 1 3.5 1.9 1.5 3 1.5s1.98.9 1.98 2ZM2 8.5h2V22H2V8.5Zm5.5 0H10v1.84h.03c.35-.66 1.21-1.35 2.47-1.35 2.64 0 3.13 1.74 3.13 4V22h-2.5v-6.33c0-1.51-.03-3.46-2.11-3.46-2.11 0-2.43 1.65-2.43 3.35V22H7.5V8.5Z" fill="#f4841f"/>
                      </svg>
                      ''',
                    ),
                    onPressed: () => launchUrl(Uri.parse('https://www.linkedin.com/in/pedrolazzaroni/')),
                    tooltip: 'LinkedIn',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StockNamePage extends StatefulWidget {
  const StockNamePage({Key? key}) : super(key: key);
  @override
  StockNamePageState createState() => StockNamePageState();
}

class StockSuggestion {
  final String symbol;
  final String name;
  final double price;
  final double annualReturn;
  final double monthlyReturn;
  StockSuggestion({required this.symbol, required this.name, required this.price, required this.annualReturn, required this.monthlyReturn});
}

class StockNamePageState extends State<StockNamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stockNameController = TextEditingController();
  List<StockSuggestion> _suggestions = [];
  bool _loading = false;
  String? _error;

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apiKey = geminiApiKey;
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' + apiKey;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final prompt = 'Você é um assistente financeiro que responde apenas em JSON. Dado o código de uma ação de qualquer país e a data de hoje ($today), responda apenas um JSON com os campos: symbol, name, price, annualReturn, monthlyReturn. O campo price deve ser o preço da ação cotado no dia $today, annualReturn é a rentabilidade dos últimos 12 meses (em decimal, ex: 0.12 para 12%), monthlyReturn é a rentabilidade dos últimos 30 dias (em decimal). Se não encontrar, retorne um array vazio.\nAção: $query';
      final body = json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      });
      final headers = {
        'Content-Type': 'application/json',
      };
      final res = await http.post(Uri.parse(url), headers: headers, body: body);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        String? content;
        try {
          content = data['candidates'][0]['content']['parts'][0]['text'];
        } catch (_) {
          content = null;
        }
        if (content == null) {
          setState(() {
            _error = 'Resposta inesperada da API Gemini.';
            _loading = false;
          });
          return;
        }
        // Limpa marcações de bloco de código do Gemini
        final cleaned = content.replaceAll(RegExp(r'```json|```', caseSensitive: false), '').trim();
        dynamic jsonResult;
        try {
          jsonResult = json.decode(cleaned);
        } catch (_) {
          setState(() {
            _error = 'Erro ao decodificar resposta da Gemini.';
            _loading = false;
          });
          return;
        }
        List<StockSuggestion> suggestions = [];
        if (jsonResult is List) {
          for (var t in jsonResult) {
            final symbol = t['symbol'] ?? '';
            final name = t['name'] ?? '';
            final price = (t['price'] ?? 0).toDouble();
            final annualReturn = (t['annualReturn'] ?? 0).toDouble();
            final monthlyReturn = (t['monthlyReturn'] ?? 0).toDouble();
            if (symbol.isNotEmpty && price > 0) {
              suggestions.add(StockSuggestion(symbol: symbol, name: name, price: price, annualReturn: annualReturn, monthlyReturn: monthlyReturn));
            }
          }
        } else if (jsonResult is Map) {
          final symbol = jsonResult['symbol'] ?? '';
          final name = jsonResult['name'] ?? '';
          final price = (jsonResult['price'] ?? 0).toDouble();
          final annualReturn = (jsonResult['annualReturn'] ?? 0).toDouble();
          final monthlyReturn = (jsonResult['monthlyReturn'] ?? 0).toDouble();
          if (symbol.isNotEmpty && price > 0) {
            suggestions.add(StockSuggestion(symbol: symbol, name: name, price: price, annualReturn: annualReturn, monthlyReturn: monthlyReturn));
          }
        }
        setState(() {
          _suggestions = suggestions;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erro ao buscar ações (status ${res.statusCode})';
          _loading = false;
        });
        return;
      }
    } catch (e, st) {
      setState(() {
        _error = 'Erro de conexão ou parsing.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderFooterScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Buscar ação',
                style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Digite o código da ação (ex: PETR4, VALE3, AAPL, TSLA) e clique em Pesquisar.',
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Aviso: Os dados exibidos são fornecidos pela API Gemini 2.0 Flash do Google. Eles podem não ser precisos ou atuais, pois o modelo foi treinado até dezembro de 2023.',
                style: GoogleFonts.roboto(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockNameController,
                      decoration: InputDecoration(
                        labelText: 'Código da ação',
                        prefixIcon: Icon(Icons.business, color: Colors.orange),
                      ),
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _fetchSuggestions(_stockNameController.text.trim());
                    },
                    child: Text('Pesquisar'),
                  ),
                ],
              ),
              if (_loading) ...[
                SizedBox(height: 16),
                CircularProgressIndicator(color: Colors.orange),
              ],
              if (_error != null) ...[
                SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Colors.red)),
              ],
              if (_suggestions.isNotEmpty) ...[
                SizedBox(height: 16),
                ..._suggestions.map((s) => Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: Text('${s.symbol} - ${s.name}', style: GoogleFonts.roboto(color: Colors.orange)),
                    subtitle: Text('Preço: R\$ ${s.price.toStringAsFixed(2)} | Rent. anual: ${(s.annualReturn*100).toStringAsFixed(2)}% | Rent. mensal: ${(s.monthlyReturn*100).toStringAsFixed(2)}%', style: GoogleFonts.roboto(color: Colors.white70)),
                    onTap: () {
                      Navigator.of(context).pushNamed('/investment', arguments: {
                        'stockName': s.symbol,
                        'stockFullName': s.name,
                        'stockPrice': s.price,
                        'averageReturn': s.annualReturn,
                        'monthlyReturn': s.monthlyReturn,
                      });
                    },
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class InvestmentPage extends StatefulWidget {
  final String stockName;
  final String stockFullName;
  final double averageReturn;
  final double monthlyReturn;
  final double stockPrice;
  const InvestmentPage({required this.stockName, required this.stockFullName, required this.averageReturn, required this.monthlyReturn, required this.stockPrice, Key? key}) : super(key: key);
  @override
  InvestmentPageState createState() => InvestmentPageState();
}

class InvestmentPageState extends State<InvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _recurringController = TextEditingController();
  String _period = 'anual';
  final List<String> _periodOptions = ['anual', 'mensal'];
  double? _futureValue;
  List<double> _chartData = [];
  List<Map<String, dynamic>> _history = [];
  final List<Map<String, dynamic>> _comparisons = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];
    setState(() {
      _history = history.map((e) {
        try {
          return Map<String, dynamic>.from(Uri.splitQueryString(e) as Map);
        } catch (_) {
          return <String, dynamic>{};
        }
      }).where((h) => h.isNotEmpty).toList();
    });
  }

  Future<void> _saveToHistory(double invested, int years, double future) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = {
      'stock': widget.stockName,
      'invested': invested.toString(),
      'years': years.toString(),
      'future': future.toString(),
      'date': DateTime.now().toIso8601String(),
    };
    final history = prefs.getStringList('history') ?? [];
    history.add(Uri(queryParameters: entry).query);
    await prefs.setStringList('history', history.take(10).toList()); // Limita a 10
    _loadHistory();
  }

  void calculateFutureValue() {
    final invested = double.tryParse(_amountController.text) ?? 0;
    final recurring = double.tryParse(_recurringController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    if (invested > 0 && years > 0) {
      final List<double> chart = [];
      double value = invested;
      int periods = _period == 'anual' ? years : years * 12;
      double rate = _period == 'anual' ? widget.averageReturn : widget.monthlyReturn;
      for (int i = 0; i <= periods; i++) {
        chart.add(value);
        value = value * (1 + rate) + recurring;
      }
      final future = chart.last;
      setState(() {
        _futureValue = future;
        _chartData = chart;
      });
      _saveToHistory(invested, years, future);
    }
  }

  void _addComparison() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _comparisons.add({
          'stockName': widget.stockName,
          'stockFullName': widget.stockFullName,
          'averageReturn': widget.averageReturn,
          'monthlyReturn': widget.monthlyReturn,
          'stockPrice': widget.stockPrice,
          'invested': _amountController.text,
          'recurring': _recurringController.text,
          'years': _yearsController.text,
          'period': _period,
        });
        _amountController.clear();
        _recurringController.clear();
        _yearsController.clear();
      });
      Navigator.of(context).pushReplacementNamed('/stockName');
    }
  }

  void _shareResult() {
    if (_futureValue != null) {
      Share.share(
        'Simulação StockCalc\nAção: ${widget.stockName}\nInvestido: R\$ ${_amountController.text}\nTempo: ${_yearsController.text} anos\nValor futuro: R\$ ${_futureValue!.toStringAsFixed(2)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderFooterScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Preencha os dados abaixo para simular o valor futuro do seu investimento nesta ação.',
                  style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Card(
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          widget.stockFullName,
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Preço atual: R\$ ${NumberFormat.simpleCurrency(name: 'BRL').format(widget.stockPrice)}',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rentabilidade média anual: ${(widget.averageReturn * 100).toStringAsFixed(2)}%',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rentabilidade média mensal: ${(widget.monthlyReturn * 100).toStringAsFixed(2)}%',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Tooltip(
                  message: 'Valor inicial a ser investido, sem aportes mensais.',
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quanto deseja investir (R\$)',
                      prefixIcon: Icon(Icons.attach_money, color: Colors.orange),
                    ),
                    style: GoogleFonts.roboto(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o valor a investir';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                Tooltip(
                  message: 'Aporte extra a cada período.',
                  child: TextFormField(
                    controller: _recurringController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Aporte recorrente (R\$)',
                      prefixIcon: Icon(Icons.repeat, color: Colors.orange),
                    ),
                    style: GoogleFonts.roboto(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Período:', style: GoogleFonts.roboto(color: Colors.orange)),
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _periodOptions.contains(_period) ? _period : _periodOptions.first,
                      dropdownColor: Colors.black,
                      style: GoogleFonts.roboto(color: Colors.orange),
                      items: _periodOptions.map((p) => DropdownMenuItem(value: p, child: Text(p == 'anual' ? 'Anual' : 'Mensal'))).toList(),
                      onChanged: (v) => setState(() => _period = v!),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Tooltip(
                  message: 'Tempo total do investimento em anos.',
                  child: TextFormField(
                    controller: _yearsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Por quantos anos?',
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.orange),
                    ),
                    style: GoogleFonts.roboto(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o tempo de investimento';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            calculateFutureValue();
                          }
                        },
                        child: Text('Calcular'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _addComparison,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange),
                          foregroundColor: Colors.orange,
                        ),
                        child: Text('Adicionar ação'),
                      ),
                    ),
                  ],
                ),
                if (_futureValue != null) ...[
                  SizedBox(height: 24),
                  Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Valor futuro estimado:',
                            style: GoogleFonts.montserrat(
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'R\$ ${NumberFormat.simpleCurrency(name: 'BRL').format(_futureValue)}',
                            style: GoogleFonts.montserrat(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()}a', style: TextStyle(color: Colors.orange, fontSize: 10));
                                    }),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      for (int i = 0; i < _chartData.length; i++)
                                        FlSpot(i.toDouble(), _chartData[i]),
                                    ],
                                    isCurved: true,
                                    color: Colors.orange,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _shareResult,
                                icon: Icon(Icons.share),
                                label: Text('Compartilhar'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const StockNamePage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;
                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: Icon(Icons.restart_alt),
                                label: Text('Recomeçar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 32),
                if (_comparisons.isNotEmpty) ...[
                  Text('Comparação de Ações', style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 18)),
                  SizedBox(height: 8),
                  ..._comparisons.map((c) => Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text('${c['stockName']} - ${c['stockFullName']}', style: GoogleFonts.roboto(color: Colors.orange)),
                      subtitle: Text('Investido: R\$ ${c['invested']} | Aporte: R\$ ${c['recurring']} | ${c['years']} anos (${c['period']})', style: GoogleFonts.roboto(color: Colors.white70)),
                    ),
                  )),
                ],
                SizedBox(height: 32),
                if (_history.isNotEmpty) ...[
                  Text('Histórico de Simulações', style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 18)),
                  SizedBox(height: 8),
                  ..._history.map((h) => Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text('${h['stock']}', style: GoogleFonts.roboto(color: Colors.orange)),
                      subtitle: Text('Investido: R\$ ${h['invested']} | Futuro: R\$ ${double.parse(h['future']).toStringAsFixed(2)} | ${h['years']} anos', style: GoogleFonts.roboto(color: Colors.white70)),
                      trailing: Text(DateFormat('dd/MM/yy').format(DateTime.parse(h['date'])), style: GoogleFonts.roboto(color: Colors.white38)),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history') ?? [];
    setState(() {
      _history = history.map((e) {
        try {
          return Map<String, dynamic>.from(Uri.splitQueryString(e) as Map);
        } catch (_) {
          return <String, dynamic>{};
        }
      }).where((h) => h.isNotEmpty).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderFooterScaffold(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico de Simulações', style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: _history.isEmpty
                  ? Center(child: Text('Nenhum histórico encontrado.', style: GoogleFonts.roboto(color: Colors.white70)))
                  : ListView(
                      children: _history.map((h) => Card(
                        color: Colors.white10,
                        child: ListTile(
                          title: Text('${h['stock']}', style: GoogleFonts.roboto(color: Colors.orange)),
                          subtitle: Text('Investido: R\$ ${h['invested']} | Futuro: R\$ ${double.parse(h['future']).toStringAsFixed(2)} | ${h['years']} anos', style: GoogleFonts.roboto(color: Colors.white70)),
                          trailing: Text(DateFormat('dd/MM/yy').format(DateTime.parse(h['date'])), style: GoogleFonts.roboto(color: Colors.white38)),
                        ),
                      )).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
