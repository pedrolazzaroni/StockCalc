import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      home: StockCalcHomePage(),
    );
  }
}

class StockCalcHomePage extends StatefulWidget {
  @override
  _StockCalcHomePageState createState() => _StockCalcHomePageState();
}

class _StockCalcHomePageState extends State<StockCalcHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double? _stockPrice;
  double? _averageReturn;
  double? _futureValue;
  String? _stockName;
  bool _loading = false;
  String? _error;

  Future<void> fetchStockData(String symbol) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apiKey = 'SUA_API_KEY';
      final url =
          'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Time Series (Daily)'] != null) {
          final prices = data['Time Series (Daily)'] as Map<String, dynamic>;
          final lastDay = prices.keys.first;
          final lastClose = double.parse(prices[lastDay]['4. close']);
          final avgReturn = 0.12;
          setState(() {
            _stockPrice = lastClose;
            _averageReturn = avgReturn;
            _stockName = symbol.toUpperCase();
          });
        } else {
          setState(() {
            _error = 'Ação não encontrada.';
          });
        }
      } else {
        setState(() {
          _error = 'Erro ao buscar dados.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro de conexão.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void calculateFutureValue() {
    if (_stockPrice != null && _averageReturn != null) {
      final invested = double.tryParse(_amountController.text) ?? 0;
      final years = int.tryParse(_yearsController.text) ?? 0;
      final future = invested * (pow(1 + _averageReturn!, years));
      setState(() {
        _futureValue = future;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StockCalc'),
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
              Text(
                'Calculadora de Ações',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Nome da ação (ex: PETR4.SA)',
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o nome da ação'
                    : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await fetchStockData(_stockController.text.trim());
                        }
                      },
                child: _loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Buscar preço'),
              ),
              if (_error != null) ...[
                SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Colors.red)),
              ],
              if (_stockPrice != null) ...[
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
                          '$_stockName',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Preço atual: R\$ ${_stockPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rentabilidade média anual: ${(100 * _averageReturn!).toStringAsFixed(2)}%',
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
                  keyboardType: TextInputType.number,
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
            ],
          ),
        ),
      ),
    );
  }
}
