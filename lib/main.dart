import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/design_viewmodel.dart';
import 'viewmodels/wardrobe_viewmodel.dart';
import 'viewmodels/measurement_viewmodel.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
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
        ChangeNotifierProvider(create: (context) => OrderViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tailor App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006D77),
            primary: const Color(0xFF006D77),
            secondary: const Color(0xFF7C3AED),
            tertiary: const Color(0xFFE76F51),
            surface: const Color(0xFFF6F8F7),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF6F8F7),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Color(0xFFF6F8F7),
            foregroundColor: Color(0xFF182322),
            titleTextStyle: TextStyle(
              color: Color(0xFF182322),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFDDE7E4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFDDE7E4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF006D77), width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFDDE7E4)),
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
              side: BorderSide(color: Color(0xFFBFD5D1)),
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
