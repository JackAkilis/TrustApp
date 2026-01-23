import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/enter_passcode_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const TrustApp());
}

class TrustApp extends StatelessWidget {
  const TrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trust App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const EnterPasscodeScreen(),
    );
  }
}
