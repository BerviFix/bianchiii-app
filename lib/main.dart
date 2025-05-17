import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

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
        home: const DashboardScreen(),
      ),
    );
  }
}