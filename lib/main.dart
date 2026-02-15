

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'converter_screen.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const CalculatorApp(),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Calculator',
          theme: themeProvider.themeData,
          home: const CalculatorScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '';
  String result = '';
  bool isScientific = false;
  bool isDegree = true; // true for degrees, false for radians
  List<String> history = [];
  bool showUnitConverter = false;

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        display = '';
        result = '';
      } else if (value == '⌫') {
        if (display.isNotEmpty) {
          display = display.substring(0, display.length - 1);
        }
      } else if (value == '=') {
        try {
          result = evaluateExpression(display);
          // Save to history
          if (display.isNotEmpty && result != 'Error') {
            history.insert(0, '$display = $result');
            if (history.length > 50) {
              history.removeLast();
            }
          }
          display = result;
        } catch (e) {
          result = 'Error';
        }
      } else if (value == 'deg' || value == 'rad') {
        isDegree = !isDegree;
      } else {
        display += value;
      }
    });
  }

  String evaluateExpression(String expression) {
    try {
      // Replace symbols for evaluation
      String exp = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      // Handle scientific functions
      exp = handleScientificFunctions(exp);

      // Evaluate the expression
      final result = _evaluate(exp);

      // Format the result
      if (result == result.toInt().toDouble()) {
        return result.toInt().toString();
      } else {
        return result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      return 'Error';
    }
  }

  String handleScientificFunctions(String exp) {
    // Handle trigonometric functions
    exp = exp.replaceAllMapped(RegExp(r'sin\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      if (isDegree) value = value * pi / 180;
      return sin(value).toString();
    });

    exp = exp.replaceAllMapped(RegExp(r'cos\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      if (isDegree) value = value * pi / 180;
      return cos(value).toString();
    });

    exp = exp.replaceAllMapped(RegExp(r'tan\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      if (isDegree) value = value * pi / 180;
      return tan(value).toString();
    });

    // Handle logarithmic functions
    exp = exp.replaceAllMapped(RegExp(r'log\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      return log(value).toString();
    });

    exp = exp.replaceAllMapped(RegExp(r'ln\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      return log(value).toString();
    });

    // Handle square root
    exp = exp.replaceAllMapped(RegExp(r'√\(([\d.]+)\)'), (match) {
      double value = double.parse(match.group(1)!);
      return sqrt(value).toString();
    });

    // Replace constants
    exp = exp.replaceAll('π', pi.toString());
    exp = exp.replaceAll('e', e.toString());

    return exp;
  }

  double _evaluate(String expression) {
    // Simple expression evaluator
    expression = expression.replaceAll(' ', '');

    // Handle parentheses first
    while (expression.contains('(')) {
      int lastOpen = expression.lastIndexOf('(');
      int firstClose = expression.indexOf(')', lastOpen);
      String subExp = expression.substring(lastOpen + 1, firstClose);
      double subResult = _evaluate(subExp);
      expression = expression.replaceRange(lastOpen, firstClose + 1, subResult.toString());
    }

    // Handle multiplication and division
    while (expression.contains('*') || expression.contains('/')) {
      RegExp regex = RegExp(r'([\d.]+)([*/])([\d.]+)');
      Match? match = regex.firstMatch(expression);
      if (match != null) {
        double a = double.parse(match.group(1)!);
        String op = match.group(2)!;
        double b = double.parse(match.group(3)!);
        double result = op == '*' ? a * b : a / b;
        expression = expression.replaceFirst(regex, result.toString());
      }
    }

    // Handle addition and subtraction
    while (expression.contains('+') || (expression.contains('-') && expression.lastIndexOf('-') > 0)) {
      RegExp regex = RegExp(r'([\d.]+)([+\-])([\d.]+)');
      Match? match = regex.firstMatch(expression);
      if (match != null) {
        double a = double.parse(match.group(1)!);
        String op = match.group(2)!;
        double b = double.parse(match.group(3)!);
        double result = op == '+' ? a + b : a - b;
        expression = expression.replaceFirst(regex, result.toString());
      } else {
        break;
      }
    }

    return double.parse(expression);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: showUnitConverter ? buildUnitConverter() : buildCalculator(),
      ),
    );
  }

  Widget buildCalculator() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(isScientific ? Icons.calculate : Icons.functions),
                    onPressed: () {
                      setState(() {
                        isScientific = !isScientific;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        showUnitConverter = true;
                      });
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'history') {
                        _showHistory();
                      } else if (value == 'clear_history') {
                        setState(() {
                          history.clear();
                        });
                      } else if (value == 'toggle_theme') {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'toggle_theme',
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Row(
                              children: [
                                Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  themeProvider.isDarkMode
                                      ? 'Light Mode'
                                      : 'Dark Mode',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 20),
                            SizedBox(width: 10),
                            Text('History'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_history',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Clear History'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Display
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              display.isEmpty ? '0' : display,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),

        // Buttons
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: isScientific ? buildScientificButtons() : buildBasicButtons(),
          ),
        ),
      ],
    );
  }

  void _showHistory() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              Expanded(
                child: history.isEmpty
                    ? Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        history[index],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        // Extract the result and use it
                        String calculation = history[index];
                        String result = calculation.split(' = ').last;
                        setState(() {
                          display = result;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildUnitConverter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showUnitConverter = false;
                  });
                },
              ),
              const SizedBox(width: 16),
              Text(
                'Unit converter',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        // Grid of converters
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildConverterCard(Icons.currency_yen, 'Currency'),
                _buildConverterCard(Icons.straighten, 'Length'),
                _buildConverterCard(Icons.crop_square, 'Area'),
                _buildConverterCard(Icons.view_in_ar, 'Volume'),
                _buildConverterCard(Icons.fitness_center, 'Weight'),
                _buildConverterCard(Icons.thermostat, 'Temperature'),
                _buildConverterCard(Icons.speed, 'Speed'),
                _buildConverterCard(Icons.compress, 'Pressure'),
                _buildConverterCard(Icons.bolt, 'Power'),
                _buildConverterCard(Icons.numbers, 'Number system'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterCard(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConverterScreen(converterType: label),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBasicButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              buildButton('AC', color: Colors.grey[800]!),
              buildButton('%', color: Colors.grey[800]!),
              buildButton('⌫', color: Colors.grey[800]!),
              buildButton('÷', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
              buildButton('×', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
              buildButton('-', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
              buildButton('+', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('00'),
              buildButton('0'),
              buildButton('.'),
              buildButton('=', color: Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildScientificButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              buildButton('sin', fontSize: 18),
              buildButton('cos', fontSize: 18),
              buildButton('tan', fontSize: 18),
              buildButton(isDegree ? 'rad' : 'deg', fontSize: 18, color: Colors.orange),
              buildButton(isDegree ? 'deg' : 'rad', fontSize: 18),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('log', fontSize: 18),
              buildButton('ln', fontSize: 18),
              buildButton('(', fontSize: 18),
              buildButton(')', fontSize: 18),
              buildButton('inv', fontSize: 18),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('!', fontSize: 18),
              buildButton('AC', fontSize: 18, color: Colors.grey[800]!),
              buildButton('%', fontSize: 18, color: Colors.grey[800]!),
              buildButton('⌫', fontSize: 18, color: Colors.grey[800]!),
              buildButton('÷', fontSize: 18, color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('^', fontSize: 18),
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
              buildButton('×', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('√', fontSize: 18),
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
              buildButton('-', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('π', fontSize: 18),
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
              buildButton('+', color: Colors.grey[800]!),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              buildButton('e', fontSize: 18),
              buildButton('00'),
              buildButton('0'),
              buildButton('.'),
              buildButton('=', color: Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, {Color? color, double fontSize = 24}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.grey[850] : Colors.grey[300];
    final textColor = isDark ? Colors.white : Colors.black87;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: color ?? defaultColor,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => onButtonPressed(text),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: color == Colors.orange ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}