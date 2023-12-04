import unittest
import urllib.request
import json

URL_POKEMONS = "http://localhost:5001/pokemons"
URL_POKEMON = "http://localhost:5001/pokemon"

PAGE_SIZE = 4
POKEMON_NAME = "bulbasaur"

class TestsPokemons(unittest.TestCase):

    def read(self, url):
        response = urllib.request.urlopen(url)
        data = response.read()
        return data.decode("utf-8")
        
    def test_01_lazy_loading(self):
        dados = self.read(f"{URL_POKEMONS}/1/{PAGE_SIZE}")
        pokemons = json.loads(dados)

        self.assertEqual(len(pokemons), PAGE_SIZE)
        self.assertEqual(pokemons[0]['id'], 1)

    def test_02_search_pokemon_by_id(self):
        data = self.read(f"{URL_POKEMON}/1")
        pokemon = json.loads(data)

        self.assertEqual(pokemon['pokemon_id'], 1)

    def test_03_search_pokemon_by_name(self):
        data = self.read(f"{URL_POKEMONS}/1/{PAGE_SIZE}/{POKEMON_NAME}")
        pokemons = json.loads(data)

        for pokemon in pokemons:
            self.assertIn(POKEMON_NAME, pokemon['name'].lower())