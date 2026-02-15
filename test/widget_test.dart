import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
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
        child: Column(
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
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
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
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: color ?? Colors.grey[850],
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
                  color: color == Colors.orange ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
