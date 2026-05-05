import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/state/session.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'widgets/session_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0B0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storage = await LocalStorage.init();
  final session = Session(storage);
  await session.bootstrap();

  runApp(FifeApp(session: session));
}

class FifeApp extends StatelessWidget {
  const FifeApp({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: session,
      child: MaterialApp(
        title: 'FiFe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            return session.isSignedIn
                ? const DashboardScreen()
                : const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
