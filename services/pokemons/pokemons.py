from flask import Flask, jsonify
from urllib.request import urlopen
import mysql.connector as mysql
import json

service = Flask("pokemons")

DATABASE_SERVER = "database"
DATABASE_USER = "root"
DATABASE_PASS = "admin"
DATABASE_NAME = "pokeinfo"

def get_db_connection():
    connection = mysql.connect(host=DATABASE_SERVER, user=DATABASE_USER, password=DATABASE_PASS, database=DATABASE_NAME)

    return connection


URL_LIKES = "http://likes:5000/likes_per_feed/"
def get_total_likes(feed_id):
    url = URL_LIKES + str(feed_id)
    response = urlopen(url)
    response = response.read()
    response = json.loads(response)

    return response["likes"]

@service.get("/info")
def get_info():
    return jsonify(
        description = "pokeinfo pokemon management",
        version = "1.0"
    )

@service.get("/pokemons/<int:page>/<int:items_per_page>")
def get_pokemons(page, items_per_page):
    pokemons = []

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        "SELECT front_default, height, name, weight, base_experience, id FROM pokeinfo " +
        "ORDER BY speciesname desc " +
        "LIMIT " + str((page - 1) * items_per_page) + ", " + str(items_per_page)
    )
    pokemons = cursor.fetchall()
    if pokemons:
        for pokemon in pokemons:
            pokemon["likes"] = get_total_likes(pokemon['id'])

    connection.close()

    return jsonify(pokemons)

@service.get("/pokemons/<int:page>/<int:items_per_page>/<string:pokemon_name>")
def find_pokemons(page, items_per_page, pokemon_name):
    pokemons = []

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        "SELECT pokeinfo.front_default, pokeinfo.height, pokeinfo.name, pokeinfo.weight, pokeinfo.base_experience, pokeinfo.id FROM pokeinfo, feeds " +
        "WHERE pokeinfo.id = feeds.pokemon " +
        "AND pokeinfo.name LIKE '%" + pokemon_name + "%' "  +
        "ORDER BY data desc " +
        "LIMIT " + str((page - 1) * items_per_page) + ", " + str(items_per_page)
    )
    pokemons = cursor.fetchall()
    if pokemons:
        for pokemon in pokemons:
            pokemon["likes"] = get_total_likes(pokemon['id'])

    connection.close()

    return jsonify(pokemons)

@service.get("/pokemon/<int:feed_id>")
def find_pokemon(feed_id):
    pokemon = {}

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        "select feeds.id as pokemon_id, DATE_FORMAT(feeds.data, '%Y-%m-%d %H:%i') as data, " +
        "pokeinfo.height, pokeinfo.name, pokeinfo.weight, pokeinfo.base_experience, pokeinfo.id, " +
        "pokeinfo.front_default as front_default, pokeinfo.back_default, IFNULL(pokeinfo.back_default, '') as back_default, " +
        "IFNULL(pokeinfo.front_shiny, '') as front_shiny " +
        "FROM feeds, pokeinfo " +
        "WHERE pokeinfo.id = feeds.pokemon " +
        "AND feeds.id = " + str(feed_id)
    )
    pokemon = cursor.fetchone()
    if pokemon:
        pokemon["likes"] = get_total_likes(feed_id)

    connection.close()

    return jsonify(pokemon)


if __name__ == "__main__":
    service.run(host="0.0.0.0", debug=True)