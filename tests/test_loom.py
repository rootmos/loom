import unittest

from client import Client
client = Client()

class LoomTests(unittest.TestCase):
    def test_ping(self):
        self.assertEqual(client.ping(), "pong")

    def test_info(self):
        i = client.info()
        self.assertEqual(i["network"], "arweave.N.1")

    def test_block(self):
        h = client.info()["current"]
        b = client.block(h)
        self.assertEqual(h, b["indep_hash"])
