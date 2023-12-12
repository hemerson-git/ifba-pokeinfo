import unittest
from tests_comments import *
from tests_pokemons import *
from tests_likes import *

if __name__ == "__main__":
    loader = unittest.TestLoader()
    tests = unittest.TestSuite()

    tests.addTest(loader.loadTestsFromTestCase(TestsPokemons))
    tests.addTest(loader.loadTestsFromTestCase(TestsComments))
    tests.addTest(loader.loadTestsFromTestCase(TestsLikes))

    runner = unittest.TextTestRunner()
    runner.run(tests)