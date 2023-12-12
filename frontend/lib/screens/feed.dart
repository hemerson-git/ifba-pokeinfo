// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pokeinfo/apis/services.dart';
import 'package:pokeinfo/auth.dart';
import 'package:pokeinfo/components/card_pokemon.dart';
import 'package:pokeinfo/state.dart';

class Pokemons extends StatefulWidget {
  const Pokemons({super.key});

  @override
  State<StatefulWidget> createState() => PokemonsState();
}

const PAGE_SIZE = 6;

class PokemonsState extends State<Pokemons> {
  late dynamic _staticFeed;
  List<dynamic> _pokemons = [];

  String _filter = "";
  late TextEditingController _filterController;

  bool _isLoading = false;
  int _nextPage = 1;

  late ServicePokemons _servicePokemons;

  @override
  void initState() {
    _filterController = TextEditingController();

    _getLoggedUser();
    _servicePokemons = ServicePokemons();
    _loadPokemons();

    super.initState();
  }

  void _getLoggedUser() {
    Auth.recoverUser().then((user) {
      if (user != null) {
        setState(() {
          appState.onLogin(user);
        });
      }
    });
  }

  Future<void> _readStaticFeed() async {
    final stringJson = await rootBundle.loadString('assets/json/pokemons.json');
    _staticFeed = await json.decode(stringJson);

    _loadPokemons();
  }

  void _loadPokemons() {
    setState(() {
      _isLoading = true;
    });

    if (_filter.isNotEmpty) {
      _servicePokemons
        .findPokemons(_nextPage, PAGE_SIZE, _filter)
        .then((pokemons) {
          setState(() {
            _isLoading = false;
            _nextPage += 1;

            _pokemons.addAll(pokemons);
          });
        });
    } else {
      _servicePokemons
        .getPokemons(_nextPage, PAGE_SIZE)
        .then((pokemons) {
          setState(() {
            _isLoading = false;
            _nextPage += 1;

            _pokemons.addAll(pokemons);
          });
        });
    }
  }

  Future<void> _updatePokemonsList() async {
    _pokemons = [];
    _nextPage = 1;

    _loadPokemons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const SizedBox.shrink(),
          actions: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                  controller: _filterController,
                  onSubmitted: (text) {
                    _filter = text;

                    _updatePokemonsList();
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search))),
            )),
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: appState.hasLoggedUser()
                    ? GestureDetector(
                        onTap: () {
                          Auth.logout().then((_) {
                            Fluttertoast.showToast(
                                msg: "You are not connected anymore!");

                            setState(() {
                              appState.onLogout();
                            });
                          });
                        },
                        child: const Icon(Icons.logout, size: 30))
                    : GestureDetector(
                        onTap: () {
                          Auth.login().then((user) {
                            Fluttertoast.showToast(
                                msg: "You have been disconnected");

                            setState(() {
                              appState.onLogin(user);
                            });
                          });
                        },
                        child: const Icon(Icons.person, size: 30)))
          ],
        ),
        body: FlatList(
          data: _pokemons,
          loading: _isLoading,
          numColumns: 2,
          onRefresh: () {
            _filter = "";
            _filterController.clear();

            return _updatePokemonsList();
          },
          onEndReached: () {
            _loadPokemons();
          },
          onEndReachedDelta: 200,
          buildItem: (item, int index) {
            return CardPokemon(item);
          },
          listEmptyWidget: Container(
              alignment: Alignment.center,
              child: const Text("There is no more pokemons to be shown 😞")),
        ));
  }
}
