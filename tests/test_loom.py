import unittest

from client import Client
client = Client()

class LoomTests(unittest.TestCase):
    def test_ping(self):
        self.assertEqual(client.ping(), "pong")
