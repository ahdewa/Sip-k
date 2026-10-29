import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/home_screen.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/services/fcm_service.dart';
import 'package:simodis_jatim/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FcmService.initialize();
  // Muat sesi login yang tersimpan (misal saat browser di-refresh Ctrl + R)
  final savedRole = await SessionService.loadSavedSession();
  runApp(SimodisJatimApp(initialRole: savedRole));
}

class SimodisJatimApp extends StatelessWidget {
  final String? initialRole;

  const SimodisJatimApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan themeMode
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        // Mendengarkan perubahan skala teks (teks lebih besar)
        return ValueListenableBuilder<double>(
          valueListenable: ThemeService.textScaleNotifier,
          builder: (context, textScale, _) {
            return MaterialApp(
              title: 'OVBS',
              debugShowCheckedModeBanner: false,
              navigatorKey: rootNavigatorKey,
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              theme: ThemeService.lightTheme,
              darkTheme: ThemeService.darkTheme,
              themeMode: currentMode,
              home: initialRole != null
                  ? HomeScreen(role: initialRole!)
                  : const LoginScreen(),
              // builder menerapkan textScaleFactor ke seluruh widget tree
              // Ini adalah cara paling efektif untuk mengubah ukuran teks global
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
