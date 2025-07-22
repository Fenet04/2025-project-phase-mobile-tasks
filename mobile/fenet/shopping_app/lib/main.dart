import 'package:flutter/material.dart';
import 'home_page.dart';
import 'details_page.dart';
import 'add_update_page.dart';
import 'search_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String homeRoute = '/';
  static const String detailsRoute = '/details';
  static const String addUpdateRoute = '/add_update';
  static const String searchRoute = '/search';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: homeRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case homeRoute:
            return MaterialPageRoute(builder: (_) => HomePage());
          case detailsRoute:
            final args = settings.arguments as Map<String, dynamic>;
            return PageRouteBuilder(
              pageBuilder: (_,__,___) => DetailsPage(product: args),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1,0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          case addUpdateRoute:
            final product = settings.arguments;
            return PageRouteBuilder(
              pageBuilder: (_,__,___) => AddUpdatePage(
                product: product is Map<String, dynamic> ? product : null,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: Offset(1,0), end: Offset.zero).animate(animation),
                  child: child,
                );
              }
            );
          case searchRoute:
            final args = settings.arguments;
            if (args is List<Map<String,dynamic>>) {
              return PageRouteBuilder(
              pageBuilder: (_,__,___) => SearchPage(products:args),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1,0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              }
            );
            }
            return _errorRoute("Missing or invalid arguments for SearchPage.");
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text("Page Not Found")),
              ),
            );
        }
      },
    );
  }
  Route _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text(message)),
      )
    );
  }
}