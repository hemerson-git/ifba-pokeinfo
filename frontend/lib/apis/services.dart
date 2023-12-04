import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokeinfo/auth.dart';

final URL_SERVICES = Uri.parse("http://192.168.1.46");

final URL_POKEMONS = "${URL_SERVICES.toString()}:5001/pokemons";
final URL_POKEMON = "${URL_SERVICES.toString()}:5001/pokemon";

final URL_COMMENTS = "${URL_SERVICES.toString()}:5002/comments";
final URL_ADD_COMMENT = "${URL_SERVICES.toString()}:5002/add";
final URL_REMOVE_COMMENT = "${URL_SERVICES.toString()}:5002/remove";

final URL_LIKED = "${URL_SERVICES.toString()}:5003/liked";
final URL_LIKE = "${URL_SERVICES.toString()}:5003/like";
final URL_UNLIKE = "${URL_SERVICES.toString()}:5003/unlike";

class ServicePokemons {
    Future<List<dynamic>> getPokemons(int page, int pageSize) async {
        final response = await http
            .get(Uri.parse("${URL_POKEMONS.toString()}/$page/$pageSize"));
        final pokemons = jsonDecode(response.body);

        return pokemons;
    }

    Future<List<dynamic>> findPokemons(int page, int pageSize, String name) async {
        final response = await http
            .get(Uri.parse("${URL_POKEMONS.toString()}/$page/$pageSize/$name"));
        final pokemons = jsonDecode(response.body);

        return pokemons;
    }

    Future<Map<String, dynamic>> findPokemon(int idPokemon) async {
    final response =
        await http.get(Uri.parse("${URL_POKEMON.toString()}/$idPokemon"));
    final pokemon = jsonDecode(response.body);

    return pokemon;
  }
}

class ServiceLikes {
  Future<bool> hasLiked(User user, int idPokemon) async {
    final response = await http
        .get(Uri.parse("${URL_LIKED.toString()}/${user.email}/$idPokemon"));
    final result = jsonDecode(response.body);

    return result["liked"] as bool;
  }

  Future<dynamic> like(User user, int idPokemon) async {
    final response = await http.post(
        Uri.parse("${URL_LIKE.toString()}/${user.email}/$idPokemon"));

    return jsonDecode(response.body);
  }

  Future<dynamic> unlike(User user, int idPokemon) async {
    final response = await http.post(
        Uri.parse("${URL_UNLIKE.toString()}/${user.email}/$idPokemon"));

    return jsonDecode(response.body);
  }
}

class ServiceComments {
  Future<List<dynamic>> getComments(
    int idPokemon,
    int page,
    int pageSize
) async {
    final response = await http.get(Uri.parse(
        "${URL_COMMENTS.toString()}/$idPokemon/$page/$pageSize"));
    final comments = jsonDecode(response.body);

    return comments;
  }

Future<dynamic> add(
    int idPokemon, 
    User user,
    String comment
) async {
    final response = await http.post(Uri.parse(
        "${URL_ADD_COMMENT.toString()}/$idPokemon/${user.name}/${user.email}/$comment"));

    return jsonDecode(response.body);
  }

  Future<dynamic> remove(int idComment) async {
    final response = await http.delete(
        Uri.parse("${URL_REMOVE_COMMENT.toString()}/$idComment"));

    return jsonDecode(response.body);
  }
}
