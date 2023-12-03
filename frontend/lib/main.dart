import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokeinfo/state.dart';
import 'package:provider/provider.dart';

import 'screens/details.dart';
import 'screens/feed.dart';

void main() {
  runApp(const Marcas());
}

class Marcas extends StatelessWidget {
  const Marcas({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          title: 'Melhores Marcas',
          theme: ThemeData(
            colorScheme: const ColorScheme.light(),
            useMaterial3: true,
          ),
          home: const TelaPrincipal(),
        ));
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  void _exibirComoRetrato() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _exibirComoRetrato();

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
