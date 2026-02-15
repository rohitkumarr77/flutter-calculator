<<<<<<< HEAD
# Flutter Calculator App

A beautiful dark-themed calculator app with both basic and scientific modes, inspired by modern mobile calculator designs.

## Features

- 🎨 Dark theme with circular buttons
- 🔢 Basic arithmetic operations (addition, subtraction, multiplication, division)
- 🔬 Scientific mode with:
    - Trigonometric functions (sin, cos, tan)
    - Logarithmic functions (log, ln)
    - Constants (π, e)
    - Square root and power operations
    - Parentheses support
- 🌡️ Degree/Radian mode toggle
- 📱 Responsive design
- ✨ Smooth animations and Material Design

## Screenshots

The app includes two modes:
1. **Basic Mode**: Simple calculator with essential operations
2. **Scientific Mode**: Advanced mathematical functions

## How to Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter plugins
- An Android/iOS emulator or physical device

### Installation Steps

1. **Clone or extract the project**

2. **Navigate to the project directory**
   ```bash
   cd calculator_project
   ```

3. **Get Flutter packages**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### For Web
```bash
flutter run -d chrome
```

### For Android
```bash
flutter run -d android
```

### For iOS (macOS only)
```bash
flutter run -d ios
```

## Usage

### Basic Mode
- Tap number buttons to input values
- Use operation buttons (+, -, ×, ÷) for calculations
- Tap "=" to see the result
- "AC" clears all input
- "⌫" deletes the last character
- "%" calculates percentage

### Scientific Mode
- Tap the function icon in the top bar to toggle scientific mode
- Use trigonometric functions: sin, cos, tan
- Toggle between degree and radian modes
- Use logarithmic functions: log, ln
- Access constants: π (pi), e (Euler's number)
- Use parentheses for complex expressions
- Square root (√) and power (^) operations

## Project Structure

```
calculator_project/
├── lib/
│   └── main.dart          # Main application code
├── pubspec.yaml           # Project dependencies
└── README.md             # This file
```

## Key Components

### `CalculatorApp`
- Main application widget with dark theme

### `CalculatorScreen`
- Main calculator interface
- Manages state and layout

### `_CalculatorScreenState`
- Handles button presses
- Expression evaluation
- Scientific calculations
- UI rendering

## Technical Details

- **Framework**: Flutter
- **Language**: Dart
- **UI**: Material Design with custom dark theme
- **Architecture**: StatefulWidget for reactive UI
- **Math Operations**: Using Dart's `dart:math` library

## Customization

You can customize the calculator by modifying:

- **Colors**: Change button colors in the `buildButton` method
- **Button Size**: Adjust padding in the `buildButton` method
- **Font Size**: Modify `fontSize` parameters
- **Layout**: Edit the grid structure in `buildBasicButtons` and `buildScientificButtons`

## Known Limitations

- Complex expression parsing may have edge cases
- Limited to standard mathematical operations
- No calculation history feature

## Future Enhancements

- [ ] Calculation history
- [ ] More scientific functions (inverse trig, hyperbolic functions)
- [ ] Graphing calculator mode
- [ ] Custom themes
- [ ] Haptic feedback
- [ ] Landscape mode optimization

## License

This project is open source and available for educational purposes.

## Support

For issues or questions, please create an issue in the project repository.

---

Developed with Flutter 💙
=======
# flutter-calculator
>>>>>>> 13c7b97b2f722a066adf0df15a25bc2c8b31d1f8
