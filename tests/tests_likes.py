import unittest
import urllib.request
import json

URL_LIKE = "http://localhost:5003/like"
URL_UNLIKE = "http://localhost:5003/unlike"
URL_LIKES_PER_FEED = "http://localhost:5003/likes_per_feed"

PAGE_SIZE = 4
LIKE_EMAIL = "hemerson@gmail.com"

class TestsLikes(unittest.TestCase):

    def read(self, url):
        response = urllib.request.urlopen(url)
        data = response.read()
        return data.decode("utf-8")
    
    def send(self, url, method):
        request = urllib.request.Request(url, method=method)
        response = urllib.request.urlopen(request)
        data = response.read()

        return data.decode("utf-8")
        
    def test_01_add_like(self):
        data = self.send(f"{URL_LIKE}/{LIKE_EMAIL}/1", "POST")
        response = json.loads(data)

        self.assertEqual(response['status'], "ok")

    def test_02_remove_like(self):
        data = self.send(f"{URL_UNLIKE}/{LIKE_EMAIL}/1", "POST")
        response = json.loads(data)

        self.assertEqual(response['status'], "ok")