import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/design_viewmodel.dart';
import 'viewmodels/wardrobe_viewmodel.dart';
import 'viewmodels/measurement_viewmodel.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'views/main_home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => DesignViewModel()),
        ChangeNotifierProvider(create: (context) => WardrobeViewModel()),
        ChangeNotifierProvider(create: (context) => MeasurementViewModel()),
        ChangeNotifierProvider(create: (context) => PaymentViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false ,
        title: 'Tailor App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.teal,
            tertiary: Colors.amber,
            surface: const Color(0xFFF7F7FA),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F7FA),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Color(0xFFF7F7FA),
            foregroundColor: Color(0xFF1D1B20),
            titleTextStyle: TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE4E1EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE4E1EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFE9E5F0)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Color(0xFFD5CDE2)),
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return authViewModel.isLoggedIn ? MainHomeView() : LoginView();
          },
        ),
        routes: {
          '/login': (context) => LoginView(),
          '/home': (context) => MainHomeView(),
        },
      ),
    );
  }
}
