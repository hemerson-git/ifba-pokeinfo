import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokeinfo/state.dart';
import 'package:provider/provider.dart';

import 'screens/details.dart';
import 'screens/feed.dart';

void main() {
  runApp(const Pokeinfo());
}

class Pokeinfo extends StatelessWidget {
  const Pokeinfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          title: 'Pokeinfo',
          theme: ThemeData(
            colorScheme: const ColorScheme.light(),
            useMaterial3: true,
          ),
          home: const MainScreen(),
        ));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _show_portrait() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _show_portrait();

    appState = context.watch<AppState>();
    Widget tela = const SizedBox.shrink();
    if (appState.situation == Situation.showingMainFeed) {
      tela = const Pokemons();
    } else if (appState.situation == Situation.showingDetails) {
      tela = const Details();
    }

    return tela;
  }
}
