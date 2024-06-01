import 'package:flutter/material.dart';
import 'package:number_trivia/features/number_trivia/presentation/pages/number_trivia_page.dart';

import 'injection_container.dart' as di;

void main() async {
  di.setup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Number Trivia',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(32, 73, 3, 0.808),
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all<Size?>(
                const Size.fromHeight(40),
              ),
              textStyle: WidgetStateProperty.all<TextStyle?>(
                const TextStyle(fontSize: 18),
              ),
              shape: WidgetStateProperty.all<OutlinedBorder?>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
              ),
              backgroundColor: WidgetStateProperty.all<Color?>(
                const Color.fromRGBO(66, 152, 4, 0.808),
              ),
            ),
          ),
        ),
        home: const NumberTriviaPage());
  }
}
