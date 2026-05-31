import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/system_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Sorter',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/system-detail': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is Map<String, dynamic>) {
            return SystemDetailScreen(
              systemName: arguments['name']?.toString() ?? '',
              systemId: arguments['id']?.toString(),
            );
          }

          return SystemDetailScreen(
            systemName: arguments is String ? arguments : '',
          );
        },
      },
    );
  }
}
