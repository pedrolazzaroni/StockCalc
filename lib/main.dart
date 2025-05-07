import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(StockCalcApp());
}

class StockCalcApp extends StatelessWidget {
  const StockCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockCalc',
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.orange,
          secondary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.orange),
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
        switch (settings.name) {
          case '/stockName':
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => StockNamePage(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            );
          case '/averageReturn':
            final args = settings.arguments as Map<String, dynamic>;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  AverageReturnPage(stockName: args['stockName']),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                  position:
                      Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim),
                  child: child),
            );
          case '/stockPrice':
            final args = settings.arguments as Map<String, dynamic>;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => StockPricePage(
                  stockName: args['stockName'],
                  averageReturn: args['averageReturn']),
              transitionsBuilder: (_, anim, __, child) =>
                  ScaleTransition(scale: anim, child: child),
            );
          case '/investment':
            final args = settings.arguments as Map<String, dynamic>;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => InvestmentPage(
                stockName: args['stockName'],
                averageReturn: args['averageReturn'],
                stockPrice: args['stockPrice'],
              ),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            );
          default:
            return null;
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/stockName');
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
            Icon(Icons.show_chart, color: Colors.orange, size: 80),
            SizedBox(height: 24),
            Text('StockCalc',
                style: TextStyle(
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

class StockNamePage extends StatefulWidget {
  @override
  _StockNamePageState createState() => _StockNamePageState();
}

class _StockNamePageState extends State<StockNamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stockNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nome da Ação'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _stockNameController,
                decoration: InputDecoration(
                  labelText: 'Nome da ação (ex: PETR4)',
                  prefixIcon: Icon(Icons.business, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o nome da ação'
                    : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pushNamed('/averageReturn',
                        arguments: {
                          'stockName': _stockNameController.text.trim(),
                        });
                  }
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AverageReturnPage extends StatefulWidget {
  final String stockName;
  AverageReturnPage({required this.stockName});
  @override
  _AverageReturnPageState createState() => _AverageReturnPageState();
}

class _AverageReturnPageState extends State<AverageReturnPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _averageReturnController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rentabilidade Média'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ação: ${widget.stockName}',
                  style: TextStyle(color: Colors.orange, fontSize: 18)),
              SizedBox(height: 16),
              TextFormField(
                controller: _averageReturnController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Rentabilidade média anual (%)',
                  prefixIcon: Icon(Icons.percent, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  final v = double.tryParse(value ?? '');
                  if (v == null || v <= 0)
                    return 'Informe uma rentabilidade válida';
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pushNamed('/stockPrice', arguments: {
                      'stockName': widget.stockName,
                      'averageReturn':
                          double.parse(_averageReturnController.text) / 100,
                    });
                  }
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockPricePage extends StatefulWidget {
  final String stockName;
  final double averageReturn;
  StockPricePage({required this.stockName, required this.averageReturn});
  @override
  _StockPricePageState createState() => _StockPricePageState();
}

class _StockPricePageState extends State<StockPricePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stockPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preço Atual'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ação: ${widget.stockName}',
                  style: TextStyle(color: Colors.orange, fontSize: 18)),
              SizedBox(height: 16),
              TextFormField(
                controller: _stockPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Preço atual da ação (R\$)',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  final v = double.tryParse(value ?? '');
                  if (v == null || v <= 0) return 'Informe um preço válido';
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pushNamed('/investment', arguments: {
                      'stockName': widget.stockName,
                      'averageReturn': widget.averageReturn,
                      'stockPrice': double.parse(_stockPriceController.text),
                    });
                  }
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvestmentPage extends StatefulWidget {
  final String stockName;
  final double averageReturn;
  final double stockPrice;
  InvestmentPage(
      {required this.stockName,
      required this.averageReturn,
      required this.stockPrice});
  @override
  _InvestmentPageState createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  double? _futureValue;

  void calculateFutureValue() {
    final invested = double.tryParse(_amountController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    if (invested > 0 && years > 0) {
      final future = invested * (pow(1 + widget.averageReturn, years));
      setState(() {
        _futureValue = future;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investimento'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                        widget.stockName,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Preço atual: R\$ ${widget.stockPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rentabilidade média anual: ${(100 * widget.averageReturn).toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quanto deseja investir (R\$)',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o valor a investir'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Por quantos anos?',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o tempo de investimento'
                    : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    calculateFutureValue();
                  }
                },
                child: Text('Calcular'),
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
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'R\$ ${_futureValue!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
