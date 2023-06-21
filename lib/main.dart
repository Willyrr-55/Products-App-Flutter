import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:products_app/screens/screens.dart';
import 'package:products_app/services/services.dart';

void main() => runApp(const AppState());

class AppState extends StatelessWidget {
  
  const AppState({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ( _ ) => AuthService()),
        ChangeNotifierProvider(create: ( _ ) => ProductsService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Products App',
      initialRoute: 'login',
      routes: {
        'checking' : (_) => const CheckAuthScreen(),

        'login': (_) => const LoginScreen(),
        'register' : (_) => const RegisterScreen(),

        'home' : (_) => const HomeScreen(),
        'product' : (_) => const ProductScreen(),
      },
      scaffoldMessengerKey: NotificationsService.messengerKey,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.indigo
        ),
        floatingActionButtonTheme:const FloatingActionButtonThemeData(
          elevation: 0,
          backgroundColor: Colors.indigo
        )
      ),
    );
  }
}