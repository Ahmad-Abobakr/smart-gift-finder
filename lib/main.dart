import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'data/data_sources/remote/api_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/home/bloc/home_bloc.dart';
import 'presentation/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // تهيئة Firebase من ملف firebase_options.dart الناتج عن `flutterfire configure`
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase غير مهيأ بعد — التطبيق يعمل بدونها.
  }
  runApp(const SmartGiftFinderApp());
}

class SmartGiftFinderApp extends StatelessWidget {
  const SmartGiftFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductRepository productRepository = ProductRepositoryImpl(
      apiDataSource: ApiDataSource(),
    );

    return RepositoryProvider<ProductRepository>.value(
      value: productRepository,
      child: BlocProvider(
        create: (context) => HomeBloc(
          productRepository: context.read<ProductRepository>(),
        ),
        child: MaterialApp(
          title: 'Smart Gift Finder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
