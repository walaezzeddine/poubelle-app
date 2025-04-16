import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poubelle/screens/admin-dashboard-screen.dart';
import 'package:poubelle/screens/auth/reset_password_screen.dart';
import 'package:poubelle/screens/collector-dashboard-screen.dart';
import 'package:poubelle/screens/user-dashboard-screen.dart';
import 'package:poubelle/screens/manage-sites-screen.dart';
import 'package:poubelle/screens/manage-users-screen.dart';
import 'package:poubelle/screens/statistics-screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'package:poubelle/screens/manage-poubelles-screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Poubelle App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (_) => const AdminDashboardScreen(),
          '/collector': (_) => const CollectorDashboardScreen(),
         '/user': (_) => const UserDashboardScreen(),
          '/reset-password': (context) => const PasswordResetScreen(),
          '/manage-users': (context) => ManageUsersScreen(),
          '/manage-sites': (context) => ManageSitesScreen(),
          '/statistics': (context) => StatisticsScreen(),
          '/manage-poubelles': (context) => ContainerCreationPage(),
        },
        onUnknownRoute: (settings) { 
          return MaterialPageRoute(
            builder: (_) => LoginScreen(),
          );
        },
      ),
    );
  }
}