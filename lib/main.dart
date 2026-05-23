import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_scaffold.dart';
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const Bu3qarApp());
}

class Bu3qarApp extends StatelessWidget {
  const Bu3qarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بوعقار',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const MainScaffold(),
    );
  }
}
