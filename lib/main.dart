import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/data_sources/remote/api_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/home/bloc/home_bloc.dart';
import 'presentation/home/home_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعدادات Firebase بتاعت مشروع smart-gift-finder-d8eee (نسخة الويب)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCz_QquMVR99ILrTt4okXw0z8aCCcIdMs4",
      authDomain: "smart-gift-finder-d8eee.firebaseapp.com",
      projectId: "smart-gift-finder-d8eee",
      storageBucket: "smart-gift-finder-d8eee.firebasestorage.app",
      messagingSenderId: "810091208013",
      appId: "1:810091208013:web:c1fca412fe7312d609eb04",
      measurementId: "G-M3BR4Q5F0D",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تركيب الطبقات: ApiDataSource -> Repository -> Bloc
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
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
