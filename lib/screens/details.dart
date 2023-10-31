import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:share_plus/share_plus.dart';

import '../state.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<StatefulWidget> createState() => DetailsState();
}

const pageSize = 4;

class DetailsState extends State<Details> {
  late dynamic _staticFeed;
  late dynamic _staticComments;

  late PageController _controladorSlides;
  late int _selectedSlide;

  bool _hasPokemon = false;
  dynamic _pokemon;

  bool _hasComments = false;
  List<dynamic> _comments = [];
  late TextEditingController _newCommentsController;
  bool _isLoadingComments = false;

  int _nextPage = 1;

  bool _liked = false;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    _loadDataBase();
    _startSlide();

    _newCommentsController = TextEditingController();

    super.initState();
  }

  void _startSlide() {
    _selectedSlide = 0;
    _controladorSlides = PageController(initialPage: _selectedSlide);
  }

  Future<void> _loadDataBase() async {
    String stringJson =
        await rootBundle.loadString('assets/json/pokemons.json');
    _staticFeed = await json.decode(stringJson);

    stringJson = await rootBundle.loadString('assets/json/comments.json');
    _staticComments = await json.decode(stringJson);

    _loadPokemons();
    _loadComments();
  }

  void _loadPokemons() {
    _pokemon = _staticFeed['pokemons']
        .firstWhere((pokemon) => pokemon['id'] == appState.idPokemon);

    setState(() {
      _hasPokemon = _pokemon != null;

      _isLoadingComments = false;
    });
  }

  void _loadComments() {
    setState(() {
      _isLoadingComments = true;
    });

    var moreComments = [];
    _staticComments['comments'].where((item) {
      return item['feed'] == appState.idPokemon;
    }).forEach((item) {
      moreComments.add(item);
    });

    final totalCommentsToLoad = _nextPage * pageSize;
    if (moreComments.length >= totalCommentsToLoad) {
      moreComments = moreComments.sublist(0, totalCommentsToLoad);
    }

    setState(() {
      _hasComments = moreComments.isNotEmpty;
      _comments = moreComments;

      _nextPage += 1;

      _isLoadingComments = false;
    });
  }

  Future<void> _updateComments() async {
    _comments = [];
    _nextPage = 1;

    _loadComments();
  }

  void _addComements() {
    if (appState.user != null) {
      final comment = {
        "content": _newCommentsController.text,
        "user": {
          "name": appState.user!.name,
          "email": appState.user!.email,
        },
        "datetime": DateTime.now().toString(),
        "feed": appState.idPokemon
      };

      setState(() {
        _comments.insert(0, comment);
      });
    }
  }

  String _formatarData(String dataHora) {
    DateTime dateTime = DateTime.parse(dataHora);
    DateFormat formatador = DateFormat("dd/MM/yyyy HH:mm");

    return formatador.format(dateTime);
  }

  Widget _showInexistentCommentsMessage() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('There is no comments yet!',
                style: TextStyle(color: Colors.black, fontSize: 14))));
  }

  List<Widget> _showComments() {
    return [
      const Center(
          child: Text(
        "Comments",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      )),
      appState.hasLoggedUser()
          ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextField(
                  controller: _newCommentsController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'Type your comment...',
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _addComements();
                          },
                          child: const Icon(Icons.send)))))
          : const SizedBox.shrink(),
      _hasComments
          ? Expanded(
              child: FlatList(
              data: _comments,
              loading: _isLoadingComments,
              numColumns: 1,
              onRefresh: () {
                _newCommentsController.clear();

                return _updateComments();
              },
              onEndReached: () {
                _loadComments();
              },
              onEndReachedDelta: 200,
              buildItem: (item, int index) {
                return Dismissible(
                    key: Key(_comments[index]['_id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red,
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: Icon(Icons.delete)))),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        final comment = _comments[index];
                        setState(() {
                          _comments.removeAt(index);
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext contexto) {
                              return AlertDialog(
                                title: const Text(
                                    "Do you really want to delete the comment?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _comments.insert(index, comment);
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("no")),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {});

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("yes"))
                                ],
                              );
                            });
                      }
                    },
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              _comments[index]["content"],
                              style: const TextStyle(fontSize: 12),
                            )),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, left: 6.0),
                                    child: Text(
                                      _comments[index]["user"]["name"],
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      _formatarData(
                                          _comments[index]["datetime"]),
                                      style: const TextStyle(fontSize: 12),
                                    )),
                              ],
                            )),
                      ],
                    )));
              },
              listEmptyWidget: Container(
                  alignment: Alignment.center,
                  child: const Text("There is no pokemon to be shown 😞")),
            ))
          : _showInexistentCommentsMessage()
    ];
  }

  Widget _showProducts() {
    List<Widget> widgets = [];

    if (!_isKeyboardVisible) {
      widgets.addAll([
        SizedBox(
          height: 120,
          child: Stack(children: [
            PageView.builder(
              itemCount: 3,
              controller: _controladorSlides,
              onPageChanged: (slide) {
                setState(() {
                  _selectedSlide = slide;
                });
              },
              itemBuilder: (context, pagePosition) {
                const types = ["front_default", "back_default", "front_shiny"];
                return Image.network(
                  _pokemon["sprites"][types[pagePosition]],
                  width: 200,
                );
              },
            ),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  appState.hasLoggedUser()
                      ? IconButton(
                          onPressed: () {
                            if (_liked) {
                              setState(() {
                                _pokemon['likes'] = _pokemon['likes'] - 1;

                                _liked = false;
                              });
                            } else {
                              setState(() {
                                _pokemon['likes'] = _pokemon['likes'] + 1;

                                _liked = true;
                              });
                            }
                          },
                          icon: Icon(
                              _liked ? Icons.favorite : Icons.favorite_border),
                          color: Colors.red,
                          iconSize: 32)
                      : const SizedBox.shrink(),
                  IconButton(
                      onPressed: () {
                        final texto =
                            '😊 ${_pokemon["name"]}: Look at this pokemon, download Pokeinfo on playstore to get more pokemons infos!';

                        Share.share(texto);
                      },
                      icon: const Icon(Icons.share),
                      color: Colors.blue,
                      iconSize: 32)
                ]))
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: PageViewDotIndicator(
            currentItem: _selectedSlide,
            count: 3,
            unselectedColor: Colors.black26,
            selectedColor: Colors.blue,
            duration: const Duration(milliseconds: 200),
            boxShape: BoxShape.circle,
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hasPokemon
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Name",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _pokemon["name"],
                                  style: const TextStyle(fontSize: 16),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Height",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _pokemon["height"].toString(),
                                  style: const TextStyle(fontSize: 16),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Weight",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _pokemon["weight"].toString(),
                                  style: const TextStyle(fontSize: 16),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "base XP",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _pokemon["base_experience"].toString(),
                                  style: const TextStyle(fontSize: 16),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Abilities",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _pokemon['abilities']
                                      .map<Widget>(
                                        (item) => Text(item["ability"]["name"]),
                                      )
                                      .toList(),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Types",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _pokemon['types']
                                      .map<Widget>(
                                          (item) => Text(item["type"]["name"]))
                                      .toList(),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Forms",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _pokemon['forms']
                                      .map<Widget>((item) => Text(item["name"]))
                                      .toList(),
                                )
                              ]),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.favorite,
                                      color: Colors.red, size: 24),
                                  Text(
                                    _pokemon["likes"].toString(),
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ]),
                          )
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        )
      ]);
    }
    widgets.addAll(_showComments());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  _pokemon["name"].toString().toUpperCase(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              appState.showPokemons();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _showInexistentMessage() {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
              onPressed: () {
                appState.showPokemons();
              },
              child: const Icon(Icons.arrow_back))),
      const Material(
          color: Colors.transparent,
          child: Text("pokemon doesn't exists",
              style: TextStyle(color: Colors.black, fontSize: 14))),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibility(
        onChanged: (bool visivel) {
          setState(() {
            _isKeyboardVisible = visivel;
          });
        },
        child: _hasPokemon ? _showProducts() : _showInexistentMessage());
  }
}
