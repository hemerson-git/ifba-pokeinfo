import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pokeinfo/apis/services.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../state.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<StatefulWidget> createState() => DetailsState();
}

const PAGE_SIZE = 4;

class DetailsState extends State<Details> {
  late dynamic _staticFeed;
  late dynamic _staticComments;

  late PageController _sliderController;
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

  late ServicePokemons _servicePokemons;
  late ServiceLikes _serviceLikes;
  late ServiceComments _serviceComments;

  @override
  void initState() {
    _startSlide();

    _newCommentsController = TextEditingController();

    _servicePokemons = ServicePokemons();
    _serviceLikes = ServiceLikes();
    _serviceComments = ServiceComments();

    _loadPokemon();
    _loadComments();

    super.initState();
  }

  void _startSlide() {
    _selectedSlide = 0;
    _sliderController = PageController(initialPage: _selectedSlide);
  }

  void _loadPokemon() {
    _servicePokemons.findPokemon(appState.idPokemon).then((pokemon) {
      _pokemon = pokemon;

      if(appState.user != null) {
        _serviceLikes
          .hasLiked(appState.user!, appState.idPokemon)
          .then((hasLiked) {
            setState(() {
              _hasPokemon = _pokemon != null;
              _liked = hasLiked;
              
              _isLoadingComments = false;
            });
          });
      } else {
        setState(() {
          _hasPokemon = _pokemon != null;
          _isLoadingComments = false;
        });
      }
    });
  }

   void _loadComments() {
    setState(() {
      _isLoadingComments = true;
    });

    _serviceComments
      .getComments(appState.idPokemon, _nextPage, PAGE_SIZE)
      .then((comments) {
        setState(() {
          _comments.addAll(comments);
          _hasComments = _comments.isNotEmpty;
          _nextPage += 1;

          _isLoadingComments = false;
        });
      });
  }

  Future<void> _updateComments() async {
    _comments = [];
    _nextPage = 1;

    _loadComments();
  }

  void _addComment() {
    _serviceComments
        .add(
          appState.idPokemon, appState.user!,
          _newCommentsController.text
        )
        .then((result) {
      if (result["status"] == "ok") {
        Fluttertoast.showToast(msg: "Comments added successfully!");

        _updateComments();
      }
    });
  }

  void _removeComment(int idComment) {
    _serviceComments.remove(idComment).then((result) {
      if (result["status"] == "ok") {
        Fluttertoast.showToast(msg: "Comment removed successfully!");

        _updateComments();
      }
    });
  }

  String _formatDate(String dateHour) {
    DateTime dateTime = DateTime.parse(dateHour);
    DateFormat formatter = DateFormat("dd/MM/yyyy HH:mm");

    return formatter.format(dateTime);
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
                            _addComment();
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
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                    "Do you really want to delete the comment?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _loadComments();
                                        });

                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("no")),
                                  TextButton(
                                      onPressed: () {
                                        _removeComment(
                                          item["comment_id"]
                                        );

                                        Navigator.of(context).pop();
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
                              _comments[index]["comment"],
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
                                      _comments[index]["name"],
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      _formatDate(
                                          _comments[index]["date"]),
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
              controller: _sliderController,
              onPageChanged: (slide) {
                setState(() {
                  _selectedSlide = slide;
                });
              },
              itemBuilder: (context, pagePosition) {
                const types = ["front_default", "back_default", "front_shiny"];
                return Image.network(
                  _pokemon[types[pagePosition]],
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
                              _serviceLikes
                                .unlike(appState.user!, appState.idPokemon)
                                .then((result) {
                                  if (result["status"] == "ok") {
                                    Fluttertoast.showToast(
                                      msg: "Like removed! 😞"
                                    );

                                    setState(() {
                                      _loadPokemon();
                                    });
                                  }
                                });
                            } else {
                              _serviceLikes
                                  .like(appState.user!, appState.idPokemon)
                                  .then((result) {
                                    if (result["status"] == "ok") {
                                      Fluttertoast.showToast(
                                        msg: "Liked! 😊"
                                      );

                                      setState(() {
                                        _loadPokemon();
                                      });
                                    }
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
                                  children: [
                                    Text(_pokemon['ability0'].toString()),
                                    Text(_pokemon['ability1'].toString())
                                  ]
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
                                  children: [
                                    Text(_pokemon['type0'].toString()),
                                    Text(_pokemon['type1'].toString())
                                  ]
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
                                  children: [
                                    Text(_pokemon['form'].toString())
                                  ]
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
