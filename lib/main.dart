import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/sub_agent.dart';
import 'models/housemaid.dart';
import 'models/transaction_model.dart';
import 'models/maid_status.dart';
import 'models/settings_model.dart';
import 'providers/notification_service.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle global errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  try {
    await Hive.initFlutter();

    Hive.registerAdapter(MaidStatusAdapter());
    Hive.registerAdapter(SubAgentAdapter());
    Hive.registerAdapter(HousemaidAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    await Hive.openBox<SubAgent>('sub_agents');
    await Hive.openBox<Housemaid>('housemaids');
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<SettingsModel>('settings');

    await NotificationService.init();
  } catch (e) {
    debugPrint('Initialization Error: $e');
  }

  runApp(const ProviderScope(child: AgentryApp()));
}

class AgentryApp extends ConsumerWidget {
  const AgentryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Agentry',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(dark: false),
      darkTheme: buildAppTheme(dark: true),
      themeMode:
          settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(settings.languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DashboardScreen(),
    );
  }
}
