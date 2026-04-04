import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'data/repositories/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class DateLuvApp extends StatefulWidget {
  const DateLuvApp({super.key});

  @override
  State<DateLuvApp> createState() => _DateLuvAppState();
}

class _DateLuvAppState extends State<DateLuvApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(context.read<AppProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          title: 'Date Luv',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          locale: provider.locale,
        );
      },
    );
  }
}
