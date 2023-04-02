import 'package:flutter/material.dart';
import 'package:project_food/bloc/auth_cubit.dart';
import 'package:project_food/bloc/location_cubit.dart';
import 'package:project_food/screens/chat_support_screen.dart';
import 'package:project_food/screens/item_screen.dart';
import 'package:project_food/screens/auth_screen.dart';
import 'package:project_food/screens/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_food/screens/map_screen.dart';
import 'package:project_food/screens/order_history.dart';
import 'package:project_food/screens/order_info.dart';
import 'package:project_food/screens/profile_screen.dart';
import 'package:project_food/screens/text_support_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webRecaptchaSiteKey:
        "apps.googleusercontent.com",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget _buildStartScreen() {
    return FirebaseAuth.instance.currentUser != null
        ? MainScreen()
        : AuthScreen();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(
          create: (context) => LocationCubit(),
        ),
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
      ],
      child: MaterialApp(
        title: 'Project Food',
        theme: ThemeData.light(),
        home: _buildStartScreen(),
        routes: {
          AuthScreen.id: (context) => AuthScreen(),
          MainScreen.id: (context) => MainScreen(),
          MapScreen.id: (context) => MapScreen(),
          ProfileScreen.id: (context) => ProfileScreen(),
          OrderHistory.id: (context) => OrderHistory(),
          TextSupportScreen.id: (context) => TextSupportScreen(),
          ChatScreen.id: (context) => ChatScreen(),
          ItemScreen.id: (context) => ItemScreen(),
          OrderInfo.id: (context) => OrderInfo(),
        },
      ),
    );
  }
}
