import 'package:flutter/material.dart';

import 'package:pokeinfo/auth.dart';

enum Situation { showingMainFeed, showingDetails }

class AppState extends ChangeNotifier {
  Situation _situation = Situation.showingMainFeed;
  Situation get situation => _situation;
  set situation(Situation situation) {
    _situation = situation;
  }

  int _idPokemon = 0;
  int get idPokemon => _idPokemon;
  set idPokemon(int idPokemon) {
    _idPokemon = idPokemon;
  }

  User? _user;
  User? get user => _user;
  set user(User? user) {
    _user = user;
  }

  void showPokemons() {
    situation = Situation.showingMainFeed;

    notifyListeners();
  }

  void showDetails(int idPokemon) {
    situation = Situation.showingDetails;
    this.idPokemon = idPokemon;

    notifyListeners();
  }

  void onLogin(User user) {
    _user = user;

    notifyListeners();
  }

  void onLogout() {
    _user = null;

    notifyListeners();
  }

  bool hasLoggedUser() {
    return _user != null;
  }
}

late AppState appState;
