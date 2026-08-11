import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/data_sources/local/local_data_source.dart';
import 'data/data_sources/remote/api_data_source.dart';
import 'data/data_sources/remote/auth_data_source.dart';
import 'data/data_sources/remote/firebase_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/cart/bloc/cart_bloc.dart';
import 'presentation/favorites/bloc/favorites_bloc.dart';
import 'presentation/home/bloc/home_bloc.dart';

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

  // App Check مطلوب عشان AI Logic يشتغل على الويب
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('1234'),
  );

  final prefs = await SharedPreferences.getInstance();
  runApp(SmartGiftFinderApp(prefs: prefs));
}

class SmartGiftFinderApp extends StatelessWidget {
  final SharedPreferences prefs;

  const SmartGiftFinderApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // تركيب طبقات المنتجات: ApiDataSource -> ProductRepository -> HomeBloc
    final ProductRepository productRepository = ProductRepositoryImpl(
      apiDataSource: ApiDataSource(),
    );

    // تركيب طبقات المصادقة: AuthDataSource -> AuthRepository -> AuthBloc
    final AuthRepository authRepository = AuthRepositoryImpl(
      authDataSource: AuthDataSource(),
    );

    final localDataSource = LocalDataSource(prefs);
    final firebaseDataSource = FirebaseDataSource();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>.value(value: productRepository),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<LocalDataSource>.value(value: localDataSource),
        RepositoryProvider<FirebaseDataSource>.value(value: firebaseDataSource),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CartBloc(
              localDataSource: context.read<LocalDataSource>(),
              firebaseDataSource: context.read<FirebaseDataSource>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(
              localDataSource: context.read<LocalDataSource>(),
              firebaseDataSource: context.read<FirebaseDataSource>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Gift Finder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}