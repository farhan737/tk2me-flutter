import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tk2me_flutter/providers/auth_provider.dart';
import 'package:tk2me_flutter/providers/connection_provider.dart';
import 'package:tk2me_flutter/screens/splash_screen.dart';
import 'package:tk2me_flutter/screens/login_screen.dart';
import 'package:tk2me_flutter/screens/register_screen.dart';
import 'package:tk2me_flutter/screens/home_screen.dart';
import 'package:tk2me_flutter/screens/chat_screen.dart';
import 'package:tk2me_flutter/providers/friend_provider.dart';
import 'package:tk2me_flutter/providers/message_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'TK2ME Messenger',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/chat': (context) => const ChatScreen(),
            },
          );
        },
      ),
    );
  }
}
