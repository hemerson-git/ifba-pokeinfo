import unittest
import urllib.request
import json

URL_COMMENTS = "http://localhost:5002/comments"
URL_CREATE_COMMENT = "http://localhost:5002/add"
URL_REMOVE_COMMENT = "http://localhost:5002/remove"

PAGE_SIZE = 4
NEW_COMMENT = "TEST_COMMENT_12345"

class TestsComments(unittest.TestCase):

    def read(self, url):
        response = urllib.request.urlopen(url)
        data = response.read()

        return data.decode("utf-8")

    def send(self, url, method):
        request = urllib.request.Request(url, method=method)
        response = urllib.request.urlopen(request)
        data = response.read()

        return data.decode("utf-8")

    def test_01_lazy_loading(self):
        data = self.read(f"{URL_COMMENTS}/1/1/{PAGE_SIZE}")
        comments = json.loads(data)

        self.assertLessEqual(len(comments), PAGE_SIZE)
        for comment in comments:
            self.assertEqual(comment['pokemon_id'], 1)

    def test_02_send_comment(self):
        name = urllib.parse.quote("hemerson silva")
        comment = urllib.parse.quote(NEW_COMMENT)

        response = self.send(f"{URL_CREATE_COMMENT}/1/{name}/hemerson@gmail.com/{comment}", "POST")
        response = json.loads(response)

        self.assertEqual(response['status'], "ok")

        data = self.read(f"{URL_COMMENTS}/1/1/{PAGE_SIZE}")
        comments = json.loads(data)

        self.assertEqual(comments[0]['comment'], NEW_COMMENT)

    def test_03_remove_comment(self):
        data = self.read(f"{URL_COMMENTS}/1/1/{PAGE_SIZE}")
        comments = json.loads(data)

        comment_id = comments[0]['comment_id']

        response = self.send(f"{URL_REMOVE_COMMENT}/{comment_id}", "DELETE")
        response = json.loads(response)

        self.assertEqual(response['status'], "ok")
    