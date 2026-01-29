import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'providers/rental_provider.dart';
import 'screens/main_section.dart';
import 'screens/reports_section.dart';
import 'screens/insights_section.dart';

void main() {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RentalProvider()),
      ],
      child: MaterialApp(
        title: 'Car Rental Cost App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const MainSection(),
        routes: {
          '/reports': (context) => const ReportsSection(),
          '/insights': (context) => const InsightsSection(),
        },
      ),
    );
  }
}
