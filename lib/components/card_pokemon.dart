// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:pokeinfo/state.dart';

class CardPokemon extends StatefulWidget {
  final dynamic pokemon;

  const CardPokemon(this.pokemon, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CardPokemonState();
  }
}

class CardPokemonState extends State<CardPokemon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 280,
        child: GestureDetector(
            onTap: () {
              appState.showDetails(widget.pokemon["id"]);
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    child: Center(
                      child: Image.network(
                        widget.pokemon["sprites"]["front_default"],
                        width: 100,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          widget.pokemon["name"],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "height",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(widget.pokemon["height"].toString())
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "weight",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(widget.pokemon["weight"].toString())
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "base xp",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(widget.pokemon["base_experience"].toString())
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                        Text(
                          widget.pokemon["likes"].toString(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
