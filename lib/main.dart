import 'package:bianchiii/password_gate_page.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  await Supabase.initialize(
    url: 'https://okcqwyiafynzlapeonli.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rY3F3eWlhZnluemxhcGVvbmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NTEwMTAsImV4cCI6MjA2MzIyNzAxMH0.V3jruGFKWJTovvvyMerXJra4LjIfRxDb4His8KfMByU',
  );

  final httpLink = HttpLink(
    'https://cmsbianchiii.dev.bervifix.com/api',
    defaultHeaders: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(MediaDashboardApp(client: client));
}

class MediaDashboardApp extends StatelessWidget {
  const MediaDashboardApp({super.key, required this.client});

  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Bianchiii',
        debugShowCheckedModeBanner: false,
        theme: FlexThemeData.dark(
          scheme: FlexScheme.outerSpace,
          useMaterial3: true,
          subThemesData: const FlexSubThemesData(
            cardRadius: 24,
            defaultRadius: 24,
          ),
        ),
        themeMode: ThemeMode.dark,
        home: PasswordGatePage(
          child: const DashboardScreen(),
        ),
      ),
    );
  }
}